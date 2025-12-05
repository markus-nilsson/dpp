classdef dp_node_items_from_fields < dp_node

    % generate output with items, where each item has the following fields
    %
    % bp
    % op
    % id
    %
    % nii_fn from field_names{c} (item c gets field name c from input)
    %
    % (general fields)


    properties
        field_names;
        general_fields;
        target_field_name = 'nii_fn';
    end

    methods

        function obj = dp_node_items_from_fields(field_names, general_fields, target_field_name)
            obj.field_names = field_names;
            obj.general_fields = general_fields;

            if (nargin > 2), obj.target_field_name = target_field_name; end
        end

        function output = i2o(obj, input)

            output.id = input.id;
            for c = 1:numel(obj.field_names)
            
                % transfer key fields
                tmp.bp = input.bp;
                tmp.op = input.op;
                tmp.id = input.id;

                % xxx: generalize this
                tmp.(obj.target_field_name) = input.(obj.field_names{c}); 

                for c2 = 1:numel(obj.general_fields)
                    tmp.(obj.general_fields{c2}) = input.(obj.general_fields{c2});
                end

                output.items{c} = tmp;

            end

        end

    end
end