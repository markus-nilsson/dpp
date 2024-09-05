classdef dpm_visualize < dpm

    % 2do
    % add time stamps in the figure so we know if it is a new output
    % or, add option to clean output folder before execution


    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'visualize';
        end
        
        function opt = dp_opt(obj, opt)
            1;
        end
        

        function output = run_on_one(obj, input, output, opt)


            % Determine conditions
            if (~isfield(output, 'vis'))
                error('%s: output.vis missing', output.id);
            end

            vis = output.vis;

            if (~isfield(vis, 'field_names'))
                error('%s: output.vis.nii_fns missing, do not know what to show', output.id);
            end

            if (~isfield(vis, 'bp'))
                error('%s: output.vis.bp missing, do not know where to output', output.id);
            end

            for c = 1:numel(vis.field_names) % expect a cell array

                field_name = vis.field_names{c};

                % Determine output name
                msf_mkdir(vis.bp);

                name = output.id;
                name = strrep(name, '/', '_');
                name = strrep(name, '\', '_');

                name = strcat(name);

                output.img_fns{c} = fullfile(vis.bp, ...
                    opt.node_name, field_name, [name '.png']);


                % Find nii filename
                nii_fn = output.(field_name);

                if (~exist(nii_fn, 'file'))
                    opt.log('%s: %s not found (%s)', outout.id, nii_fn, field_name);
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
                opt.log('%s: %s done', output.id, field_name);


            end


        end

        function process_outputs(obj, outputs, opt)
            1;
        end

    end

end