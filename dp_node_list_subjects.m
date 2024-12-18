classdef dp_node_list_subjects < dp_node_primary

    properties
        bp;
        n_max = inf;
        id_exclude;

    end

    methods

        function outputs = get_iterable(obj)

            % abstract
            outputs = obj.get_outputs();

            % filter in this early stage
            outputs = dp_item.exclude(outputs, obj, obj.id_exclude);

            % trim to desired length
            outputs = outputs(1:min(end, obj.n_max));

            

        end

    end

    methods (Abstract)

        outputs = get_outputs(obj)

    end

end