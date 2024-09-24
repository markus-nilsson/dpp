classdef dp_node_dcm2nii_and_xps < dp_node_workflow

    methods

        function obj = dp_node_dcm2nii_and_xps()

            a = dp_node_dcm2nii();
            b = dp_node_make_xps();

            obj = obj@dp_node_workflow({a,b});
            
        end
    end
end