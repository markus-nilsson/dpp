classdef dp_node < dp_node_base

    % intention of this node is to implement methods dealing with file io 

    methods

        function obj = dp_node()
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj), ...
                dpm_mgui(obj), ...
                dpm_visualize(obj)};
        end


        function output = run_clean(obj, output)
            
            % xxx: move this, make it private, and then 
            %      have it run function handles instead

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            if (~isfield(output, 'tmp')), return; end

            output.tmp = msf_ensure_field(output.tmp, 'do_delete', 0);
            
            if (output.tmp.do_delete)
                msf_delete(output.tmp.bp);
            end

        end

        function [status, f, age] = input_exist(obj, input)
            [status, f, age] = obj.io_exist2(input, obj.input_test);
        end

        function [status, f, age] = output_exist(obj, output)
            [status, f, age] = obj.io_exist2(output, obj.output_test);
        end

        function output = visualize(obj, input, output)

            for c = 1:numel(vis.field_names) % expect a cell array

                field_name = vis.field_names{c};

                % Determine output name
                msf_mkdir(vis.bp);

                name = output.id;
                name = strrep(name, '/', '_');
                name = strrep(name, '\', '_');

                name = strcat(name);

                output.img_fns{c} = fullfile(vis.bp, ...
                    obj.node.name, field_name, [name '.png']);


                % Find nii filename
                nii_fn = output.(field_name);

                if (~exist(nii_fn, 'file'))
                    obj.node.log('%s: %s not found (%s)', outout.id, nii_fn, field_name);
                    continue;
                end

                [I,h] = mdm_nii_read(nii_fn);

                I = mgui_misc_flip_volume(I, mdm_nii_oricode(h), 'LAS');

                nk = min(25, size(I,3));
                kmod = round(size(I,3) / nk);
                k = max(1, round( (size(I,3) - nk * kmod) / 2));


                ni = 1 + floor(sqrt(nk));
                nj = ceil(nk / ni);

                B = [];
                for i = 1:ni
                    A = [];
                    for j = 1:nj
                        if (k > size(I,3))
                            A = cat(1, A, zeros(size(I, [1 2])));
                        else
                            A = cat(1, A, I(:,:,k, 1));
                        end
                        k = k + kmod;
                    end
                    B = cat(2, B, A);
                end

                msf_clf;
                msf_imagesc(B);
                [~,name] = msf_fileparts(nii_fn);
                title(strrep(name, '_', ' '));
                colormap gray;
                clim([0 quantile(B(:), 0.99)]);
                pause(0.1);

                msf_mkdir(fileparts(output.img_fns{c}));
                print(output.img_fns{c}, '-dpng');
                obj.node.log('%s: %s done', output.id, field_name);

            end
        end

    end

    methods (Hidden, Static)

        % run a function on the input/output structures
        % these should be moved elsewhere        
        % sorry for the poor naming

        function [status, f, age] = io_exist2(io, test_fields)

            if (~isempty(test_fields)) % test only the fields asked for
                
                for c = 1:numel(test_fields)

                    if (~isfield(io, test_fields{c}))
                        disp(fieldnames(io)); % error will be thrown
                    end

                    tmp.(test_fields{c}) = io.(test_fields{c});
                end
                do_pass_empty = 0;
            else
                tmp = io;
                do_pass_empty = 1;
            end

            [status, f, age] = dp_node.io_exist(tmp, do_pass_empty);

        end

        function [status, f, age] = io_exist(io, do_pass_empty)

            if (nargin < 2)
                do_pass_empty = 1;
            end

            % select fields with names ending with _fn
            f = fieldnames(io);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));

            % Report the presence of the files
            status = zeros(size(f));
            age = zeros(size(f));

            for c = 1:numel(f)
            
                status(c) = exist(io.(f{c}), 'file') == 2;

                if (status(c))
                    d = dir(io.(f{c}));
                    age(c) = d.datenum;
                else
                    age(c) = NaN;
                end

                % allow empties to pass
                if (isempty(io.(f{c}))) && (do_pass_empty)
                    status(c) = 1; 
                end
            end

            status2 = cellfun( @(x) exist(io.(x), 'file') == 2, f);

        end        


        function str = join_cell_str(f)

            g = @(x) x(1:(end-3));
            
            str = g(cell2mat(cellfun(@(x) cat(2, x, ' / '), f, ...
                'UniformOutput', false)));
        end
        
        

    end

end