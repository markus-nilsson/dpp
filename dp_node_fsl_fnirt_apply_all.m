classdef dp_node_fsl_fnirt_apply_all < dp_node_workflow

    % apply non-linear warp from fnirt to many 

    methods

        function obj = dp_node_fsl_fnirt_apply_all(field_names)

            % turn fields into items
            % run apply on each
            % distill into separate fields

            general_fields = {'warp_fn', 'target_fn'};

            a = dp_node_items_from_fields(field_names, general_fields);
            b = dp_node_items(dp_node_fsl_fnirt_apply);
            c = dp_node_items_to_fields(field_names);

            obj = obj@dp_node_workflow({a,b,c});

        end

    end
end