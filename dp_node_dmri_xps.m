classdef dp_node_dmri_xps < dp_node

    methods

        function obj = dp_node_dmri_xps()
            obj.output_test = {'dmri_fn', 'xps_fn'};
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