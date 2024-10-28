classdef dp_node_items < dp_node_base

    % iterate with nodes over items within a node

    properties
        inner_node;
    end

    methods (Hidden)

        function output_items = items_fun(obj, f, varargin)

            % deal with input
            input_items = varargin{1};

            if (numel(varargin) == 2) 
                % 1-2 mapping (1 output, 2 inputs)
                g = f;
                output_items = varargin{2};
            else 
                % 1-1 mapping
                g = @(x,y) f(x);
                output_items = cell(size(input_items));
            end

            for c = 1:numel(input_items)

                obj.log(2, '%s: Item %i %s', input_items{c}.id, c, strtrim(formattedDisplayText(f)));

                if (obj.opt.do_try_catch)

                    try
                        output_items{c} = g(input_items{c}, output_items{c}); %#ok<AGROW>
                    catch me

                        if (strcmp(obj.mode, 'report'))
                            obj.log(1, '%s --> %s\n', input_items{c}.id, ...
                                me.message);
                        end
                    end

                else
                    output_items{c} = g(input_items{c}, output_items{c}); %#ok<AGROW>
                end

            end            
        end

    end

    methods

        function obj = dp_node_items(inner_node)
            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_report_items(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj)};   

            obj.inner_node = inner_node;
        end


        function input = po2i(obj, po)

            if (~isfield(po, 'items'))
                disp(po);
                error('Output of previous node did not have an items field');
            end
            
            input.items = obj.items_fun(@(x) obj.inner_node.po2i(x), po.items);
            
        end

        function output = i2o(obj, input)

            % not great, we're replicating functionality from 
            % main dp exeuction
            function y = i2o_inner(x)
                y = obj.inner_node.i2o(x);
                y = msf_ensure_field(y, 'id', x.id);
            end

            output.items = obj.items_fun(@i2o_inner, input.items);
            
        end

        function output = execute(obj, input, output)

            % experimental code here

            switch (obj.mode)

                case {'execute', 'debug'}

                    f = @(x,y) obj.inner_node.get_dpm(obj.mode).run_on_one(x,y);

                otherwise

                    error('this function only supports mode execute for now')

            end

            % push options through to inner node
            obj.inner_node.opt = obj.opt; 

            output.items = obj.items_fun(f, input.items, output.items);

        end

        function output = run_clean(obj, output)

            f = @(x) obj.inner_node.run_clean(x);
            output.items = obj.items_fun(f, output.items);

        end

        function [status, f, age] = input_exist(obj, input)

            status = []; f = {}; age = [];
            for c = 1:numel(input.items)
                [tmp_status, tmp_f, tmp_age] = obj.inner_node.input_exist(input.items{c});
                status = cat(1, status, tmp_status);
                f = cat(1, f, tmp_f);
                age = cat(1, age, tmp_age);
            end

        end

        function [status, f, age] = output_exist(obj, output)

            status = []; f = {}; age = [];
            for c = 1:numel(output.items)
                [tmp_status, tmp_f, tmp_age] = obj.inner_node.output_exist(output.items{c});
                status = cat(1, status, tmp_status);
                f = cat(1, f, tmp_f);
                age = cat(1, age, tmp_age);
            end

        end

    end
end