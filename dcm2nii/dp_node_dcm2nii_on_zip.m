classdef dp_node_dcm2nii_on_zip < dp_node_workflow

    methods

        function obj = dp_node_dcm2nii_on_zip()

            a = dp_node_unzip_to_tmp;
            
            b = dp_node_io_rename({...
                {'dcm_name',   'zip_name'}, ...
                {'dcm_folder', 'unzipped_folder'}});

            c = dp_node_dcm2nii_and_xps();

            obj = obj@dp_node_workflow({a,b,c});

            obj.output_test = c.output_test;            

        end
    end
end