classdef dp_node_items_from_fields < dp_node

    % generate output with items
    properties
        field_names;
        general_fields;
    end

    methods

        function obj = dp_node_items_from_fields(field_names, general_fields)
            obj.field_names = field_names;
            obj.general_fields = general_fields;
        end

        function output = i2o(obj, input)

            output.id = input.id;
            for c = 1:numel(obj.field_names)
            
                % transfer key fields
                tmp.bp = input.bp;
                tmp.op = input.op;
                tmp.id = input.id;

                % xxx: generalize this
                tmp.nii_fn = input.(obj.field_names{c}); 

                for c2 = 1:numel(obj.general_fields)
                    tmp.(obj.general_fields{c2}) = input.(obj.general_fields{c2});
                end

                output.items{c} = tmp;

            end

        end

    end
end