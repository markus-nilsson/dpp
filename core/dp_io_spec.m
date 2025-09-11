classdef dp_io_spec < handle

    properties
        spec;
        node;
        type; % input or output
        enabled = true;
    end

    methods

        function obj = dp_io_spec(node, type)
            if (nargin < 2), type = 'input'; end
            obj.node = node;
            obj.spec = {};
            obj.type = type;
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

        function f = get_mandatory_fields(obj)
            f = cellfun(@(x) x.field_name, obj.spec, 'UniformOutput', 0);
            f = f(cellfun(@(x) x.is_mandatory, obj.spec));            
        end

        function f = get_test_fields(obj)
            f = cellfun(@(x) x.field_name, obj.spec, 'UniformOutput', 0);
            f = f(cellfun(@(x) x.do_test, obj.spec));            
        end
        
        function test(obj, input)

            if (obj.enabled == false), return; end

            % fields to test
            f = obj.get_mandatory_fields();

            % legacy 
            switch (obj.type)
                case 'input'
                    f = cat(1, obj.node.input_test);
                case 'output'
                    f = cat(1, obj.node.output_test);
            end
            

            % test if the fields are in place
            tmp = {};

            % test for missing fields
            for c = 1:numel(f)
                field_name = f{c};

                if (~isfield(input, field_name))
                    tmp{end+1} = field_name; %#ok<AGROW>
                end
            end

            if (~isempty(tmp))
                error('input fields missing (%s) in %s', strjoin(tmp, ', '), obj.node.name);
            end

            
        end


        function [status, f, age] = exist(obj, io)

            status = [];
            f = [];
            age = [];

            if (obj.enabled == false), return; end

            % not yet written for the spec herein

            % test that files exist
            test_fields = obj.get_test_fields();

            if (~isempty(test_fields)) % test only the fields asked for
                
                for c = 1:numel(test_fields)

                    if (~isfield(io, test_fields{c}))
                        disp(fieldnames(io)); % error will be thrown
                    end

                    tmp.(test_fields{c}) = io.(test_fields{c});
                end
                do_pass_empty = 0;
            else
                tmp = io;
                do_pass_empty = 1;
            end

           
            % select fields with names ending with _fn
            f = fieldnames(tmp);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));

            % Report the presence of the files
            status = zeros(size(f));
            age = zeros(size(f));

            for c = 1:numel(f)

                status(c) = exist(io.(f{c}), 'file') == 2;

                if (status(c))
                    d = dir(io.(f{c}));
                    age(c) = d.datenum;
                else
                    age(c) = NaN;
                end

                % allow empties to pass
                if (isempty(io.(f{c}))) && (do_pass_empty)
                    status(c) = 1; 
                end
            end

        end        

    end

end