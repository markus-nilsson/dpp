classdef dp_node_io_set_dp < dp_node_io_append

    % Set the data path
    
    methods

        function obj = dp_node_io_set_dp(dp)
            obj = obj@dp_node_io_append({...
                {'dp', dp}, ...
                {'op', @(x) fullfile(x.bp, x.id, x.dp)}});
        end        

    end

end