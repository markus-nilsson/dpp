classdef dp_node_io_parent < dp_node

    methods

        function obj = dp_node_io_parent()
            obj.input_spec.remove('op');
        end

    end


end