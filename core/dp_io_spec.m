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

            disp(' ');

            for c_mandatory = [1 0]
                
                switch (c_mandatory)
                    case 1
                        disp('Input fields (mandatory)');
                    case 0
                        disp('Input fields (optional)');
                end

                disp(' ');

                n = max(cellfun(@(x) numel(x), obj.get_all_fields()));

                f = @(x) cat(2, x, repmat(' ', 1, n - numel(x)));

                c_fields = 0;
                for c = 1:numel(obj.spec)
                    if (obj.spec{c}.is_mandatory == c_mandatory)
                        c_fields = c_fields + 1;
                        disp(sprintf(' %i. %s - %s', c_fields, ...
                            f(obj.spec{c}.field_name), obj.spec{c}.description));
                    end
                end

                if (c_fields == 0)
                    disp(' None');
                end

                disp(' ');
            end
            

        end

        function f = get_legacy_fields(obj)
            switch (obj.type)
                case 'input'
                    f = cat(1, obj.node.input_test);
                case 'output'
                    f = cat(1, obj.node.output_test);
            end
        end

        function f = get_all_fields(obj)
            f = cellfun(@(x) x.field_name, obj.spec, 'UniformOutput', 0);            
        end

        function f = get_mandatory_fields(obj)
            f = obj.get_all_fields();
            f = f(cellfun(@(x) x.is_mandatory, obj.spec));            
        end

        function f = get_test_fields(obj, io)

            % Let the new structure be used
            f = cellfun(@(x) x.field_name, obj.spec, 'UniformOutput', 0);
            f = f(cellfun(@(x) x.do_test, obj.spec));

            if (~isempty(f)), return; end 

            % Legacy: use input/output test property
            f = obj.get_legacy_fields();

            if (~isempty(f)), return; end

            % Legacy: If not specified, use all _fn fields
            f = fieldnames(io);
            f = f(cellfun(@(x) ~isempty(strfind(x(max(1,(end-2)):end), '_fn')), f));
            
        end
        
        function test(obj, input)

            if (obj.enabled == false), return; end

            % fields to test
            f = obj.get_mandatory_fields();
            f = cat(2, f, obj.get_legacy_fields());            

            % test if the fields are in place
            tmp = {};
            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    tmp{end+1} = f{c}; %#ok<AGROW>
                end
            end

            if (~isempty(tmp))
                error('input fields missing (%s) in %s', strjoin(tmp, ', '), obj.node.name);
            end
            
        end


        function [status, f, age] = exist(obj, io)

            status = []; f = []; age = [];

            if (obj.enabled == false), return; end

            % test that files exist
            f = obj.get_test_fields(io);


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