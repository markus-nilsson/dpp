classdef dp_node_items_from_folders < dp_node_items

    % packages files in a folder as items

    properties
    end

    methods

        function obj = dp_node_items_from_folders()

            obj = obj@dp_node_items(dp_node);

        end

        % overloading to get things to work, but not nice
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end          
        
        function output = i2o(obj, input)

            di = dir(fullfile(input.ip));

            output = input;
            output.items = {};
            for c = 1:numel(di)

                if (di(c).name(1) == '.')
                    continue;
                end
                
                % found a match
                item.this_fn = fullfile(input.ip, di(c).name);
                
                % transfer mandatory files
                item.bp = input.bp;
                item.id = input.id;
                item.op = input.op;

                output.items{end+1} = item;
            end
        end

    end
end