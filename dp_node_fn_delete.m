classdef dp_node_fn_delete < dp_node

    properties
        field_name;
    end

    methods

        function obj = dp_node_fn_delete(field_name)
            obj.field_name = field_name;
        end

        function output = execute(obj, input, output)

            fn = input.(obj.field_name);

            obj.log(0, '%s: Deleting file: %s', input.id, fn);

            1;
            
            msf_delete(fn);
                
        end

    end
end