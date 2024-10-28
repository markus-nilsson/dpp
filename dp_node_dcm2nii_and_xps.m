classdef dp_node_dcm2nii_and_xps < dp_node_workflow

    methods


        function obj = dp_node_dcm2nii_and_xps()

            a = dp_node_dcm2nii();
            b = dp_node_make_xps();

            % do not test on xps here, as we apply this also to non-
            % diffusion data, where no xps will be created
            b.output_test = {'nii_fn'};

            obj = obj@dp_node_workflow({a,b});

            
            
        end
    end
end