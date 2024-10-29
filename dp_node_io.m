classdef dp_node_io < dp_node_io_append

    % Quick way to append fields (will write over existing field)
    
    methods

        function obj = dp_node_io(fi,fo)
            obj = obj@dp_node_io_append({{fi, fo}});
        end        

    end

end