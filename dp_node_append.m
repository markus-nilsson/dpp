classdef dp_node_append < dp_node_rename

    % Appends output with relabeld or computed fields

    properties
        do_overwrite_fields = 0;
    end
    
    methods

        function obj = dp_node_append(translation_table, do_overwrite)
            obj = obj@dp_node_rename(translation_table);

            if (nargin > 1)
                obj.do_overwrite_fields = do_overwrite;
            end
        end        

        function output = i2o(obj, input)
            output = i2o@dp_node_rename(obj, input);

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

    end

end