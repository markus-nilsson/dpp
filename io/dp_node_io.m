classdef dp_node_io < dp_node_io_append

    % Quick way to append fields (will write over existing field)
    
    methods

        function obj = dp_node_io(f_out,f_in)
            
            obj = obj@dp_node_io_append({{f_out, f_in}});

        end        

    end

end