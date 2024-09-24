classdef dp_node_unzip_dcm2nii < dp_node_workflow

    methods

        function obj = dp_node_unzip_dcm2nii()

            a = dp_node_unzip_to_tmp;
            b = dp_node_rename({...
                {'zip_name', 'dcm_name'}, ...
                {'unzipped_folder', 'dcm_folder'}, ...
                {'bp', 'bp'}});
            c = dp_node_dcm2nii();

            obj = obj@dp_node_workflow({a,b,c});

            obj.output_test = c.output_test;

        end
    end
end