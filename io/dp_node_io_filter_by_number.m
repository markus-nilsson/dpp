classdef dp_node_io_filter_by_number < dp_node_io_parent

    % Filter by number of outputs allowed
    properties
        n_max
    end

    methods

        function obj = dp_node_io_filter_by_number(n_max)
            obj.n_max = n_max;
        end

        function outputs = process_outputs(obj, outputs)
            outputs = outputs(1:min(end, obj.n_max));
        end
    end

end
