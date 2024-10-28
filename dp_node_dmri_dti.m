classdef dp_node_dmri_dti < dp_node

    methods

        function obj = dp_node_dmri_dti()
            obj.input_test = {'nii_fn'};
            obj.output_test = {'md_fn', 'fa_fn', 's0_fn'};
        end

        function output = i2o(obj, input)
            output.md_fn = fullfile(input.op, 'dti_lls_md.nii.gz');
            output.fa_fn = fullfile(input.op, 'dti_lls_fa.nii.gz');
            output.s0_fn = fullfile(input.op, 'dti_lls_s0.nii.gz');
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

            msf_mkdir(input.op);
            dti_lls_pipe(s, input.op, opt);

        end

    end

end




