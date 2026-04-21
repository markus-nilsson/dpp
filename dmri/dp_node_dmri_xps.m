classdef dp_node_dmri_xps < dp_node

    % Base class for diffusion MRI experimental parameter set (XPS) handling. Provides
    % framework for creating and managing acquisition parameter files from various sources.

    methods

        function obj = dp_node_dmri_xps()
            obj.output_test = {'dmri_fn', 'xps_fn'};
        end

        function output = i2o(obj, input)
            output = input;
            output.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
        end

        function output = execute(~,~,~)
            1;
        end
    end
end