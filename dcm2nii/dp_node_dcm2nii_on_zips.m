classdef dp_node_dcm2nii_on_zips < dp_node_workflow

    % searches for *.zip in input.op, unzips these, and convers to dicom

    methods

        function obj = dp_node_dcm2nii_on_zips(filter_list, filter_mode)          

            if (nargin < 1), filter_list = {}; end
            if (nargin < 2), filter_mode = 'exclude'; end

            if (nargin < 1)
                filter_list = {'.*localizer\.zip$'};
                filter_mode = 'exclude';
            end

            a = dp_node_io_files_to_items('*.zip', 'zip_fn', filter_list, filter_mode);
            b = dp_node_items(dp_node_dcm2nii_on_zip());

            obj = obj@dp_node_workflow({a,b});


        end

    end

end