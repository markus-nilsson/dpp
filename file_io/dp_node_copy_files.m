classdef dp_node_copy_files < dp_node_files_to_items

    % look in input.ip for files following filter_list and filter_mode
    % copy these to input.op

    methods

        function obj = dp_node_copy_files(ext, filter_list, filter_mode)          

            % ext - for example '*.zip'
            
            if (nargin < 2), filter_list = {}; end
            if (nargin < 3), filter_mode = 'exclude'; end

            obj = obj@dp_node_files_to_items(...
                dp_node_copy(), ext, ...
                filter_list, filter_mode);

        end

    end
end