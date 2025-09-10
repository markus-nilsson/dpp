classdef dp_node_dmri_flirt < dp_node_fsl_flirt

    % Registers fractional anisotropy (FA) maps to standard space using FSL FLIRT.
    % Performs affine coregistration for spatial normalization of diffusion-derived metrics.

    methods

        function obj = dp_node_dmri_flirt()
            obj.input_test = {'nii_fn'};
            obj.output_test = {'nii_fn'};
        end

        function input = po2i(obj, po)

            input = po; 
            
            % allow target fns from earlier steps, like in longitudinal
            % pipes
            if (~isfield(po, 'target_fn'))
                fsl_data_dir = getenv('FSLDIR'); % Get FSL directory from environment
                input.target_fn = fullfile(fsl_data_dir, 'data', 'standard', 'FMRIB58_FA_1mm.nii.gz');
            end
            
            
            input.nii_fn = po.fa_fn;
        end

        function output = i2o(obj, input)

            output = i2o@dp_node_fsl_flirt(obj, input);

            % Pass information about the dmri and mask fns, if available
            if (isfield(input, 'dmri_fn')), output.dmri_fn = input.dmri_fn; end
            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

    end
end