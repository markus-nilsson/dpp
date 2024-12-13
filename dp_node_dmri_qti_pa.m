classdef dp_node_dmri_qti_pa < dp_node

    methods

        function obj = dp_node_dmri_qti()
            obj.output_test = {'mki_fn', 'mka_fn', 'md_fn'};
        end


        function output = i2o(obj, input)

            output.dmri_fn = input.dmri_fn;
            output.xps_fn = input.xps_fn;

            output.mki_fn = fullfile(input.op, 'dtd_covariance_pa_MKi.nii.gz');
            output.mka_fn = fullfile(input.op, 'dtd_covariance_pa_MKa.nii.gz');
            output.md_fn = fullfile(input.op, 'dtd_covariance_pa_MD.nii.gz');
            output.s0_fn = fullfile(input.op, 'dtd_covariance_pa_s0.nii.gz');

        end

        function output = execute(obj, input, output)

            % diffusion data
            s = mdm_s_from_nii(input.dmri_fn);
            
            if (isfield(input, 'mask_fn') && ~isempty(input.mask_fn))
                s.mask_fn = input.mask_fn;
            end

            opt = mdm_opt;
            dtd_covariance_pa_pipe(s, output.op, opt);

        end

    end

end




