classdef dp_node_items_filter < dp_node

    properties
        filter;
    end

    methods

        function obj = dp_node_items_filter(filter)
            obj.filter = filter;
        end

        function output = i2o(obj, input)

            output.id = input.id;
            output.op = input.op;
            output.bp = input.bp;

            output.items = {};
            for c = 1:numel(input.items)

                if (obj.filter(input.items{c}))
                    output.items{end+1} = input.items{c};
                end

            end

        end

    end


end