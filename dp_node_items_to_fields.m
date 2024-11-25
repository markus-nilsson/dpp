classdef dp_node_items_to_fields < dp_node

    % generate output with fields from items
    properties
        field_names;
    end

    methods

        function obj = dp_node_items_to_fields(field_names)
            obj.field_names = field_names;
        end

        function output = i2o(obj, input)

            output.id = input.id;

            for c = 1:numel(obj.field_names)

                % xxx: generalize this
                output.(obj.field_names{c}) = input.items{c}.nii_fn;

            end

        end

    end
end