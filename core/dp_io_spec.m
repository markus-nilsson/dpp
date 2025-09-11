classdef dp_input_spec

    properties
        spec;
    end

    methods

        function obj = dp_input_spec()
            obj.spec = {};
        end

        function obj = add(obj, field_name, type, is_mandatory, do_test, description)
            obj.spec{end+1} = dp_input(field_name, type, is_mandatory, do_test, description);
        end
        
        function obj = print(obj)

            % to be written

        end

    end



end