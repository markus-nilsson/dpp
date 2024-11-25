classdef dp_node_copy_and_rename < dp_node_copy

    % this node will copy files and rename files to input.op
    %
    % translation table as { {field_name, new_filename}, ... }
    
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

                tmp = f{c};

                output.(tmp) = dp.new_fn(input.op, obj.translation_table{c}{2});

            end
            
        end

        function f = get_fieldnames_to_copy(obj, varargin)
            f = obj.field_names;
        end

    end

end