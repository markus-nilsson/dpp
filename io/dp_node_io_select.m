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
            
            f = cat(2, 'bp', 'id', 'op', obj.fields);

            for c = 1:numel(f)
                output.(f{c}) = input.(f{c});
            end

        end
    end
end
