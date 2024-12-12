classdef dp_node_dmri_qti < dp_node_dmri


    properties
        qti_opt;
    end

    methods

        function obj = dp_node_dmri_qti()
            obj.qti_opt.filter_sigma = 0.6; 
        end

        function output = i2o(obj, input)

            output.mki_fn = fullfile(input.op, 'dtd_covariance_MKi.nii.gz');
            output.mka_fn = fullfile(input.op, 'dtd_covariance_MKa.nii.gz');
            output.md_fn = fullfile(input.op, 'dtd_covariance_MD.nii.gz');
            output.s0_fn = fullfile(input.op, 'dtd_covariance_s0.nii.gz');

        end

        function output = execute(obj, input, output)

            s = mdm_s_from_nii(input.dmri_fn);
            s.mask_fn = input.mask_fn;

            dtd_covariance_pipe(s_pa, output.op, obj.qti_opt);

        end

    end

end




