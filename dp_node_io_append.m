classdef dp_node_io_append < dp_node_io_rename

    % Appends output with relabeld or computed fields

    properties
        do_overwrite_fields = 0;
    end
    
    methods

        function obj = dp_node_io_append(translation_table, do_overwrite)
            obj = obj@dp_node_io_rename(translation_table);

            if (nargin > 1)
                obj.do_overwrite_fields = do_overwrite;
            end
        end        

        function output = i2o(obj, input)

            output = i2o@dp_node_io_rename(obj, input);

            % do not write over fields, but apppend if they haven't been
            % written already
            f = fieldnames(input);
            for c = 1:numel(f)
                if (~isfield(output, f{c})) || (obj.do_overwrite_fields)
                    output.(f{c}) = input.(f{c});
                elseif (~isfield(output, f{c}))
                    error('field already set, use do_overwrite_fields')
                end
            end

        end

        function obj = update_node(obj, varargin)

            obj = update_node@dp_node_io_rename(obj, varargin{:});

            % by now, there should be a previous node set - copy its 
            % output check
            if (~isempty(obj.previous_node))
                obj.output_test = obj.previous_node.output_test;
            end

        end
        

    end

end