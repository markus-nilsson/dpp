classdef dp_io_spec < handle

    properties
        spec;
        node;
    end

    methods

        function obj = dp_io_spec(node)
            obj.node = node;
            obj.spec = {};
        end

        function obj = add(obj, field_name, type, is_mandatory, do_test, description)
            obj.spec{end+1} = dp_io(field_name, type, is_mandatory, do_test, description);
        end

        function obj = remove(obj, field_name)
            ind = cellfun(@(x) ~isequal(x.field_name, field_name), obj.spec);
            obj.spec = obj.spec(ind);
        end
        
        function obj = print(obj)

            for c = 1:numel(obj.spec)
                disp(sprintf('%s: %s', obj.spec{c}.field_name, obj.spec{c}.description));
            end

        end

        function test(obj, input, input_test)

            % test if the fields are in place
            tmp = {};

            % test for missing fields
            for c = 1:numel(obj.spec)
                field_name = obj.spec{c}.field_name;

                if (~isfield(input, field_name))
                    tmp{end+1} = field_name; %#ok<AGROW>
                end
            end

            if (~isempty(tmp))
                error('input fields missing (%s) in %s', strjoin(tmp, ', '), obj.node.name);
            end

            

            % test if the fields are in place (legacy)
            if (nargin > 2)
                tmp = {};

                % test for missing fields
                for c = 1:numel(input_test)
                    if (~isfield(input, input_test{c}))
                        tmp{end+1} = input_test{c}; %#ok<AGROW>
                    end
                end

                if (~isempty(tmp))
                    error('input fields missing (%s) in %s', strjoin(tmp, ', '), obj.node.name);
                end
            end

                       
            
        end

    end



end