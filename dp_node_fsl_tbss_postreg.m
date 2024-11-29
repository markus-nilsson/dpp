classdef dp_node_fsl_tbss_postreg < dp_node

    % make the skeleton

    properties
        tbss_bp;
        n_mask_threshold = 1400000; 
    end

    methods

        function obj = dp_node_fsl_tbss_postreg(tbss_bp)
            obj.tbss_bp = tbss_bp;
        end

        function output = i2o(obj, input)
            output.fa_fn = input.fa_fn; % for later stages
            output.mean_fa_fn = fullfile(obj.tbss_bp, 'mean_fa.nii.gz');
            output.fa_mask_fn = fullfile(obj.tbss_bp, 'fa_mask.nii.gz');
            output.mean_masked_fa_fn = fullfile(obj.tbss_bp, 'mean_fa_masked.nii.gz');
            output.fa_skeleton_fn = fullfile(obj.tbss_bp, 'fa_skeleton.nii.gz');
        end

        function outputs = execute_on_outputs(obj, outputs)

            M = []; % mask
            X = []; % average FA
            n = 0;

            for c = 1:numel(outputs)
                output = outputs{c};

                if (~exist(output.fa_fn, 'file'))
                    obj.log(0, '%s: Missing fa map', output.id);
                    continue;
                end

                [I,h] = mdm_nii_read(output.fa_fn);

                output.n_mask = sum(I(:) > 0);

                outputs{c} = output;

                if (output.n_mask == 0)
                    obj.log(0, '%s: All FA values are zero, skipping', output.id);
                    continue;
                end

                if (output.n_mask < obj.n_mask_threshold)
                    msf_imagesc(cat(1, I, X./(M+eps), M/n));
                    pause(0.5);
                    
                    obj.log(0, '%s: Small mask (%i), skipping - bad QA?', output.id, output.n_mask);
                    continue;
                end
                
                n = n + 1;

                if (n == 1)
                    M = zeros(size(I));
                    X = zeros(size(I));
                end

                M = M + (I > 0);

                X = X + double(I);

                obj.log(0, '%s: #non-zero voxels are %i', output.id, sum(I(:) > 0));

                if (1)
                    msf_imagesc(cat(1, I, X./(M+eps), M/n));
                    pause(0.5);
                end


            end


            X = X ./ (M + eps);
            M = M == n; % need FA in all volumes

            mdm_nii_write(X, output.mean_fa_fn, h);
            mdm_nii_write(int16(M), output.fa_mask_fn, h);
            mdm_nii_write(X .* double(M), output.mean_masked_fa_fn, h);

            cmd = sprintf('tbss_skeleton -i %s -o %s', ...
                output.mean_masked_fa_fn, ...
                output.fa_skeleton_fn);
            msf_system(cmd);

        end
    end

end