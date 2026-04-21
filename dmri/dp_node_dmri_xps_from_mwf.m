classdef dp_node_dmri_xps_from_mwf < dp_node_dmri_xps

    properties

        n_rf = -1; % number of samples at the gradient raster time that the RF pulse takes
        dt = 10e-6; % gradient raster sample time (e.g. 10e-6)

        resource_path = fullfile(pwd, 'fwf_library');

    end

    methods

        function obj = my_build_xps(dt, n_rf)

            if (nargin >= 1), obj.dt = dt; end
            if (nargin >= 2), obj.n_rf = round(n_rf); end

            obj.input_test = {'gwf_fn', 'dmri_fn', 'csa_fn'};
            obj.output_test = {'xps_fn'};
        end

        function output = i2o(obj, input)

            output = input;
            output.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);

        end

        function output = execute(obj, input, output)

            % expose execute method to others
            output = dp_node_dmri_xps_from_mwf.static_execute(struct(obj), input, output);

        
        end
    end

    methods (Static)

        function output = static_execute(obj, input, output)

            if (isempty(obj))
                warning off;
                obj = struct(dp_node_dmri_xps_from_mwf());
                warning on;
            end

            % --- csa header verification ---
            % verify settings relative to the csa file
            txt = mdm_txt_read(input.csa_fn);

            % search for strings in the CSA header
            f = @(str) txt(cell2mat(cellfun(@(x) contains(lower(x), lower(str)), txt, 'UniformOutput', false)));
            g = @(x) strtrim(x{1}( (find(x{1} == '=', 1) + 1) : end));
            h = @(x) str2num(x);
            k = @(x) h(g(f(x)));

            if (~strcmp(g(f('tSequenceFileName')), '""%CustomerSeq%\ep2d_diff_mwf""'))
                error('expected ep2d_diff_mwf data');
            end

            if (obj.n_rf == -1) % load from csa
                obj.n_rf = k('sWipMemBlock.alFree[5]') / 10;
            end

            % Look for the dvs file

            dvs_path = fullfile(obj.resource_path, 'dvs');
            dvs_fn = fullfile(dvs_path, ...
                cell2mat(cellfun(@(x) x(strfind(x, '#') + 3), f('sDiffusion.sFreeDiffusionData.sComment'), 'UniformOutput', false)));

            if (~exist(dvs_fn, 'file'))
                [~,tmp1, tmp2] = fileparts(dvs_fn);
                error('dvs file (%s) not found in %s', cat(2, tmp1, tmp2), dvs_path);
            end

            dvs_txt = mdm_txt_read(dvs_fn);

            f = @(x) x{1};
            gwf_path = fullfile(obj.resource_path, 'fwf');
            gwf_fn = f(dvs_txt(cellfun(@(x) contains(x, 'FWF_LIBRARY'), dvs_txt)));
            gwf_fn = strtrim(gwf_fn(2:end));
            gwf_fn = strrep(gwf_fn, 'FWF_LIBRARY', gwf_path);
            
            if (~exist(gwf_fn, 'file'))
                [~,tmp1, tmp2] = fileparts(gwf_fn);
                error('gradient binary file (%s) not found in %s', cat(2, tmp1, tmp2), gwf_path);
            end



            % --- deal with gradient waveform fin ---

            % load the gradient waveform from the bin file, assuming it
            % follows the format for Filip Szczepankiewicz's FWF v2
            % sequence
            gwf_bin = fwf_bin_read_siemens(gwf_fn);

            gwf_rf = zeros(obj.n_rf, 3); % check the in the asc conv file

            % load b-values from .bval file
            xps_tmp = mdm_xps_from_bval_bvec(input.bval_fn, input.bvec_fn, 1);

            % verify that bval and gwf bin has the same number of elements
            if (xps_tmp.n ~= size(gwf_bin, 2))
                error('Sizes of .bin file and .bval files do not match');
            end

            % assumed input at this stage: gwf, dt
            % assume the gradient waveform holds the true gradient waveform as played
            % by the scanner
            gwf = cell(1, xps_tmp.n);
            
            % Physical waveform
            for c = 1:size(gwf_bin, 2)
                gwf{c} = cat(1, gwf_bin{1,c}, gwf_rf, gwf_bin{2,c});
            end
            
            % Effects of spin echo on effective gradient waveform sign
            rf  = cat(1, ....
                +ones(size(gwf_bin{1,c}, 1), 1), ...
                +gwf_rf(:,1), ...
                -ones(size(gwf_bin{2,c}, 1), 1));
            
            % Build an xps from the tentative gradient waveform file
            xps_gwf = gwf_to_pars(gwf, rf, obj.dt);

            % Get scaling factor to adjust all gradient wavefroms
            sc = sqrt(xps_gwf.b \ xps_tmp.b);

            % Rescale all waveforms
            for c = 1:size(gwf_bin, 2)
                gwf{c} = gwf{c} * sc;
            end

            % Build an xps from the scaled gradients
            xps_gwf = gwf_to_pars(gwf, rf, obj.dt);

            % Verify that .bval and rescaled gwf gives the same b-values, 
            % using relative sum of squares
            qa_b = sum( ((xps_gwf.b - xps_tmp.b) ./ ((xps_gwf.b + xps_tmp.b + 1)/2) ).^2 );
            if (qa_b > 0.01)

                if (1)
                    msf_clf;
                    subplot(2,2,1);
                    plot(xps_gwf.b);
                    title('b-values per gwf file');

                    subplot(2,2,2);
                    plot(xps_tmp.b);
                    title('b-values per .bval file');

                    subplot(2,2,3);
                    plot(xps_gwf.b, xps_tmp.b);
                    title('gwf versus bval');

                    subplot(2,2,4);
                    plot(xps_gwf.b - xps_tmp.b);
                    title('Difference gwf - bval');
                end

                error('b-values diverge between .bval and rescaled gradient waveforms');
            end

            xps = xps_gwf;
            
            %obj.log(1, '%s: qa_b = %1.5f', input.id, qa_b);



            % RESEX specific code
            [~,nii_name] = msf_fileparts(input.dmri_fn);
            if (contains(lower(nii_name), 'resex')) % not a great way to invoke this

                gwf_effective = cell(size(gwf));
                for c = 1:size(gwf_bin, 2)

                    % Map gradient waveform onto one dimension
                    g = gwf{c} * xps_gwf.u(c,:)';

                    % verify that we have gradients in non-principal directions
                    % project back up into 3D and check for deviations
                    qa_g = sqrt(sum( (gwf{c} - g * xps_gwf.u(c,:)).^2 * obj.dt, 'all'));

                    if (qa_g > 1e-6)
                        error('this seems to be a 3D waveform, this function only accepts 1D waveforms for now');
                    end

                    % save for later use (transpose for Arthur :) )
                    gwf_effective{c} = (g .* rf)';
                end

                xps = xps_tmp;

                % assumed input at this stage: gwf, dt
                % assume the gradient waveform holds the true gradient waveform as played
                % by the scanner
                for c = 1:size(gwf_bin, 2)

                    g = gwf_effective{c};

                    q = msf_const_gamma*cumsum(g)*obj.dt;
                    b = sum(q.^2)*obj.dt;

                    N = numel(g);
                    t = 0:obj.dt:(N-1)*obj.dt;

                    q4 = (1/b^2)*resex_mc_correlate(q.^2, q.^2, obj.dt);

                    if b == 0
                        xps.b(c,1)      = 0;
                        xps.Gamma(c,1)  = 0;
                        xps.Vomega(c,1) = 0;
                        xps.q4(c, :)  = zeros(size(q));
                        xps.q(c,:)    = q;
                        xps.gwf(c,:)  = g;
                    else
                        xps.b(c,1)      = b;
                        xps.Gamma(c,1)  = 2*trapz(t, t.*q4);
                        xps.Vomega(c,1) = (1/b)*msf_const_gamma()^2*trapz(t, g.^2);
                        xps.q4(c, :)  = (1/b^2) * resex_mc_correlate(q.^2, q.^2, obj.dt);
                        xps.q(c,:)    = q;
                        xps.gwf(c,:)  = g;
                    end

                end

                % Prepare for powder averaging
                tmp = [xps.b(:) xps.Gamma(:) xps.Vomega(:)]; % column vectors so we get 82×3 (one row per measurement)
                tmp = round(tmp .* [1e-8 1e3 1e-3]);
                [~, ~, ic] = unique(tmp, 'rows','legacy'); % group identical (b, Gamma, Vomega) combinations
                xps.a_ind = ic';

            end

            mdm_xps_save(xps, output.xps_fn);

        end


    end


end 
    