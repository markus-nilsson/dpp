classdef dp_node_dcm2nii_and_xps < dp_node_workflow

    methods


        function obj = dp_node_dcm2nii_and_xps()

            a = dp_node_dcm2nii();

            % need a better solution here, to deal with information better
            b = dp_node_io('dmri_fn', 'nii_fn');
            c = dp_node_dmri_xps_make();

            obj = obj@dp_node_workflow({a,b,c});

            % do not test on xps here, as we apply this also to non-
            % diffusion data, where no xps will be created
            %
            % xxx: redo this, possibly by a merge solution
            obj.output_test = {'nii_fn'};
            
            
        end
    end
end