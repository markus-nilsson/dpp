classdef dp_node_items < dp_node_core

    % iterate with nodes over items within a node

    properties
        inner_node;
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
                error('Output of previous node did not have an items field');
            end
            
            f = @(po) obj.inner_node.po2i(po);
            input.items = obj.items_fun(f, po.items);
            
        end

        function output = i2o(obj, input)

            f = @(input) obj.inner_node.i2o(input);
            output.items = obj.items_fun(f, input.items);

            % transfer id to inner nodes
            for c = 1:numel(output.items)
                output.items{c} = msf_ensure_field(output.items{c}, 'id', input.id);
            end
            
        end

        function output = run_on_one(obj, input, output)

            f = @(input, output) obj.inner_node.run_on_one(input, output);

            % push mode through to inner node
            obj.inner_node.mode = obj.mode;

            output.items = obj.items_fun(f, input.items, output.items);

        end     

        function obj = update(obj, varargin) % set necessary properties

            obj = update@dp_node_core(obj, varargin{:});
            
            obj.inner_node.update(varargin{:});

        end        

        function output = run_clean(obj, output)

            f = @(output) obj.inner_node.run_clean(output);
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

            % insert custom error logging here
            function err_log(me, id)

                if (strcmp(obj.mode, 'report'))
                    obj.log(1, '%s --> %s\n', id, me.message);
                end

                obj.log(2, '%s: Error in dp_node_items (%s)', id, obj.name);
                obj.log(2, '%s:   %s', id, me.message);

            end

            for c = 1:numel(input_items)

                obj.log(2, '%s: Item %i %s', input_items{c}.id, c, strtrim(formattedDisplayText(f)));

                % Note that this does not implement a try-catch: 
                % a failure of one item causes a cascading error
                % that should be caught in an outer stage
                output_items{c} = obj.run_fun(...
                    @() g(input_items{c}, output_items{c}),...
                    @(me, id) err_log(me, input_items{c}.id), 0);

            end            
        end

    end    
end