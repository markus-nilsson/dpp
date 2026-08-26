classdef dp_node_io_select < dp_node_io_parent

    % selects some fields to pass on

    properties
        fields;
    end
    
    methods

        function obj = dp_node_io_select(fields)
            
            if ~iscell(fields)
                fields = {fields};
            end

            obj.fields = fields;
        end        

        function output = i2o(obj, input)
            
            % xxx: make obj property
            sys_f = {'bp', 'id', 'op', 'tmp', 'mem'};
            
            f = cat(2, sys_f, obj.fields);

            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    if (c > numel(sys_f))
                        error('field %s missing', f{c})
                    end
                    continue; 
                end
                output.(f{c}) = input.(f{c});
            end

        end
    end
end
