classdef dp_node_dmri_dti < dp_node

    methods

        function output = i2o(obj, input)

            output.op = input.op; % output ends up here

            output.md_fn = fullfile(output.op, 'dti_lls_MD.nii.gz');
            output.fa_fn = fullfile(output.op, 'dti_lls_FA.nii.gz');
            output.s0_fn = fullfile(output.op, 'dti_lls_s0.nii.gz');


        end

        function output = execute(obj, input, output)

            % diffusion data
            s = mdm_s_from_nii(input.nii_fn);

            if (isfield(input, 'mask_fn'))
                s.mask_fn = input.mask_fn;
            end

            if (~isfield(input, 'opt'))
                input.opt.present = 1;
            end

            opt = dti_lls_opt(input.opt);

            dti_lls_pipe(s, output.op, opt);

        end

    end

end




