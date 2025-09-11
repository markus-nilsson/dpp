classdef dp_node_dmri_qti < dp_node

    % Performs Q-space Trajectory Imaging (QTI) analysis for advanced diffusion modeling.
    % Computes kurtosis metrics including mean kurtosis isotropic (MKi) and anisotropic (MKa) components.

    methods

        function obj = dp_node_dmri_qti()
            obj.output_test = {'mki_fn', 'mka_fn', 'md_fn'};
            
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Diffusion MRI nifti file');
            obj.input_spec.add('xps_fn', 'file', 1, 1, 'Experimental parameter set file');
            obj.input_spec.add('mask_fn', 'file', 0, 1, 'Brain mask file (optional)');
        end


        function output = i2o(obj, input)

            output.dmri_fn = input.dmri_fn;
            output.xps_fn = input.xps_fn;

            output.mki_fn = fullfile(input.op, 'dtd_covariance_MKi.nii.gz');
            output.mka_fn = fullfile(input.op, 'dtd_covariance_MKa.nii.gz');
            output.fa_fn = fullfile(input.op, 'dtd_covariance_FA.nii.gz');
            output.md_fn = fullfile(input.op, 'dtd_covariance_MD.nii.gz');
            output.s0_fn = fullfile(input.op, 'dtd_covariance_s0.nii.gz');

        end
        

        function output = execute(obj, input, output)

            % diffusion data
            s = mdm_s_from_nii(input.dmri_fn);
            
            if (isfield(input, 'mask_fn') && ~isempty(input.mask_fn))
                s.mask_fn = input.mask_fn;
            end

            opt = mdm_opt;
            dtd_covariance_pipe(s, output.op, opt);

        end

    end

end




