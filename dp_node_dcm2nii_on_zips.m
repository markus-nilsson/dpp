classdef dp_node_dcm2nii_on_zips < dp_node_files_to_items

    methods

        function obj = dp_node_dcm2nii_on_zips(filter_list, filter_mode)          

            if (nargin < 1), filter_list = {}; end
            if (nargin < 2), filter_mode = 'exclude'; end

            % should be rewritten as a workflow that uses
            % dp_node_items_from_files instead
            
            obj = obj@dp_node_files_to_items(...
                dp_node_unzip_dcm2nii(), ...
                '*.zip', ...
                filter_list, ...
                filter_mode);

        end

    end

end