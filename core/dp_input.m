classdef dp_input

    properties
        field_name;
        type;
        is_mandatory;
        do_test;
        description;
    end

    methods

        function obj = dp_input(field_name, type, is_mandatory, do_test, description)

            % in the future, we could add extensions and other things too
            obj.field_name   = field_name;
            obj.type         = lower(type);
            obj.is_mandatory = logical(is_mandatory);
            obj.do_test      = logical(do_test);
            obj.description  = description;
            
        end

    end



end