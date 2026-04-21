classdef dp_node_items_to_fields < dp_node

    % generate output with fields from items
    properties
        field_names;
        item_field_name = 'nii_fn';
    end

    methods

        function obj = dp_node_items_to_fields(field_names, item_field_name)
            obj.field_names = field_names;
            if (nargin > 1)
                obj.item_field_name = item_field_name;
            end
        end

        function output = i2o(obj, input)

            output.id = input.id;

            for c = 1:numel(obj.field_names)

                % xxx: generalize this
                item = input.items{c};

                if (isfield(item, obj.item_field_name))
                    output.(obj.field_names{c}) = item.(obj.item_field_name);
                end

            end

        end

    end
end