classdef dp_node_primary_feed < dp_node_primary

    properties
        outputs;
    end
    
    methods

        function obj = dp_node_primary_feed(outputs)
            % takes a single output or a cell of outputs as input

            if (~iscell(outputs))
                outputs = {outputs};
            end
            
            obj.outputs = outputs;

            for c = 1:numel(outputs)
                obj.input_spec.test(outputs{c});
            end
        end

        function previous_outputs = get_iterable(obj)
            previous_outputs = obj.outputs;
        end

    end


end