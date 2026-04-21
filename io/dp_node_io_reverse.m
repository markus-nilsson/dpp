classdef dp_node_io_reverse < dp_node_io_parent

    methods

        function outputs = process_outputs(obj, outputs)
            outputs = outputs(end:-1:1);
        end
    end

end
