classdef dp_node_io_set_bp < dp_node_io_append

    % Set the base path
    % 
    % (future: consider auto-setting op)
    
    methods

        function obj = dp_node_io_set_bp(bp)
            obj = obj@dp_node_io_append({{'bp', @(x) bp}});
        end        

    end

end