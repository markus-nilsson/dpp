classdef dp_node_elastix_apply_to_many < dp_node_workflow

    % inputs
    %
    % {field_names}
    %
    % elastix_t_fn

    methods

        function obj = dp_node_elastix_apply_to_many(field_names)

            a = dp_node_items_from_fields(field_names, {'elastix_t_fn'});
            b = dp_node_items(dp_node_elastix_apply());
            c = dp_node_items_to_fields(field_names);

            obj = obj@dp_node_workflow({a,b,c});


        end


    end
end