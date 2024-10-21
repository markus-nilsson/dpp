classdef p8_qti < dp_node

    methods

        function obj = p8_qti()
            obj.previous_node = {p6_mask, p7_powder_averaging};
        end

        function input = po2i(obj, prev_output) % build input to this step from previous output

            input.nii_fn = prev_output.powder_averaging_nii_fn;
            input.mask_fn = prev_output.mask_nii_fn;

            % looks like massive smoothing, but remember, this is after
            % upsampling
            input.opt.filter_sigma = 1.2;
            input.opt.mask.do_overwrite = 0;
        end

        function output = i2o(obj, input)

            [op, name, ext] = msf_fileparts(input.nii_fn);
            output.op = op; % output ends up here

            output.mki_fn = fullfile(op, 'dtd_covariance_MKi.nii.gz');
            output.mka_fn = fullfile(op, 'dtd_covariance_MKa.nii.gz');
            output.md_fn = fullfile(op, 'dtd_covariance_MD.nii.gz');
            output.s0_fn = fullfile(op, 'dtd_covariance_s0.nii.gz');


        end

        function output = execute(obj, input, output)

            % diffusion data
            s_pa = mdm_s_from_nii(input.nii_fn);
            s_pa.mask_fn = input.mask_fn;

            dtd_covariance_pa_pipe(s_pa, output.op, opt);

        end

    end

end




