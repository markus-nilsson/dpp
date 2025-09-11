classdef dp_node_dmri_xps < dp_node

    % Base class for diffusion MRI experimental parameter set (XPS) handling. Provides
    % framework for creating and managing acquisition parameter files from various sources.

    methods

        function obj = dp_node_dmri_xps()
            obj.output_test = {'dmri_fn', 'xps_fn'};
            
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Diffusion MRI nifti file');
        end

        function output = i2o(obj, input)
            output = input;
            output.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
        end

        function output = execute(~,~,~)
            error('this is just a placeholder for subclasses') 
        end
    end
end