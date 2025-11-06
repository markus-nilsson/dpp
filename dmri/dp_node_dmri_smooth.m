classdef dp_node_dmri_smooth < dp_node_dmri

    % Applies Gaussian smoothing to diffusion MRI data. Reduces noise by spatial
    % filtering while preserving tissue boundaries and diffusion signal characteristics.

    properties
        filter_sigma = 0.6;
    end

    methods

        function obj = dp_node_dmri_smooth(filter_sigma)
            if (nargin > 0), obj.filter_sigma = filter_sigma; end
            obj.output_test = {'dmri_fn'};
            
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Diffusion MRI nifti file');
            obj.input_spec.add('mask_fn', 'file', 0, 1, 'Brain mask file (optional)');
        end

        function output = i2o(obj, input)

            % Pass information about the dmri and mask fns, if available
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_s');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            s = mdm_s_from_nii(input.dmri_fn);
            opt = mdm_opt;
            mdm_s_smooth(s, obj.filter_sigma, output.op, opt);

        end

    end
end