classdef dp_node_primary_feed < dp_node_primary

    properties
        outputs;
    end
    
    methods

        function obj = dp_node_primary_feed(outputs)
            obj.outputs = outputs;
        end

        function previous_outputs = get_iterable(obj)
            previous_outputs = obj.outputs;
        end

    end


end