classdef dp_node_copy_and_rename < dp_node_copy

    % this node will copy files and rename files to input.op
    %
    % translation table as { {field_name, new_filename*}, ... }
    %
    % *) if new_filename is a...
    % 
    %    ...char then the file (named new_filename) will be placed in input.op
    %    ...function_handle (fun) then the output filename will be fun(input)
    
    properties
        translation_table;        
    end

    methods

        function obj = dp_node_copy_and_rename(translation_table)

            if (numel(translation_table) < 1), error('need a translation table'); end
            if (~iscell(translation_table{1})), error('elements must be cells'); end

            obj.translation_table = translation_table;
            obj.field_names = cellfun(@(x) x(1), translation_table);
        end

        function output = i2o(obj, input)

            f = obj.get_fieldnames_to_copy(input);

            for c = 1:numel(f)

                tmp1 = f{c};

                tmp2 = obj.translation_table{c}{2};
                switch (class(tmp2))
                    case 'char'
                        tmp2 = dp.new_fn(input.op, tmp2);
                    case 'function_handle'
                        tmp2 = tmp2(input);
                    otherwise
                        error('second part of translation table must be char or function_handle');
                end
            
                output.(tmp1) = tmp2;

            end
            
        end

        function f = get_fieldnames_to_copy(obj, varargin)
            f = obj.field_names;
        end

    end

end