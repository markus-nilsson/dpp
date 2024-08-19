classdef dp_node

    properties

        previous_node = [];

    end


    methods

        function obj = dp_node()
        end

        % build input to this step from previous output
        function input = po2i(obj, previous_output) 
            input = previous_output;
        end

        function outputs = i2o(obj, inputs)
            outputs = inputs;
        end

        function output = execute(obj, input, output)
            1;
        end

        % 
        function previous_outputs = get_iterable(obj, opt)

            if (isempty(obj.previous_node))
                error('previous_node not defined, aborting');
            end

            % Merging needed? (I do not want the code here, but rather in
            % the main dp code, but let it be here for the moment)
            if (iscell(obj.previous_node))

                list_of_outputs = cell(size(obj.previous_node));
                node_names = cell(size(list_of_outputs));

                for c = 1:numel(list_of_outputs)
                    node_names{c} = class(obj.previous_node{c});
                    list_of_outputs{c} = dp.run(obj.previous_node{c}, opt.iter_mode, opt);
                end

                f4 = @(x,y) max([1 1 + find(x == y, 1, 'first')]);
                f3 = @(x) x(f4(x,'_'):end);
                f2 = @(x) f3(x(f4(x,'/'):end));
                f1 = @(x) f2(char(x));
                list_of_prefixes = cellfun(@(x) f1(x), node_names, 'UniformOutput',false);
                previous_outputs = dp.merge_outputs(list_of_outputs, list_of_prefixes);

                % report on outcome
                opt.log('--> Merging outputs (%s) resulted in %i items', ...
                    dp.join_cell_str(list_of_prefixes), ...
                    numel(previous_outputs));

            else % assume it is a dp_node

                previous_outputs = dp.run(obj.previous_node, opt.iter_mode, opt);
            end
        end

        function type = get_type(obj)
            type = 'ordinary';
        end

    end

end