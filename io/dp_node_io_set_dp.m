classdef dp_node_io_set_dp < dp_node_io_append

    % Set the data path
    
    methods

        function obj = dp_node_io_set_dp(dp)
            obj = obj@dp_node_io_append({...
                {'dp', @(x) dp}, ...
                {'op', @(x) fullfile(x.bp, x.id, x.dp)}});
            obj.do_rename_immediately = 1; % allows dp to be used in op set
        end        

    end

end