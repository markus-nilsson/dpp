classdef dp_node_list_subjects < dp_node_primary

    % to do: rename as dp_node_primary_list_subjects
    %        just do get_iterable directly

    properties
        bp;
    end

    methods

        function outputs = get_iterable(obj)

            % abstract
            outputs = obj.get_outputs();

        end

    end

    methods (Abstract)

        outputs = get_outputs(obj)

    end

end