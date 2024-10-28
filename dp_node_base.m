classdef dp_node_base < handle

    properties

        previous_node = [];

        name;
        mode;
        opt;

        dpm_list;

        input_test = [];  % field that will be tested by input_exists
        output_test = []; % field that will be tested by output_exists

        do_i2o_pass = 0;

    end

    properties (Hidden)
        do_dpm_passthrough = 0;
    end

    methods (Abstract)
        input_exist(obj, input);
        output_exist(obj, output);
    end

    methods

        function obj = dp_node_base()

            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj)};

        end

        % methods that we expected to be overloaded (this is where you
        % implement the processing code)

        function input = po2i(obj, previous_output) 
            input = previous_output;
        end

        function outputs = i2o(obj, inputs)
            outputs = inputs;
        end

        function output = execute(obj, input, output)
            1;
        end
        
        function output = visualize(obj, input, output)
            1;
        end

        function tmp = make_tmp(obj)

            tmp.bp = msf_tmp_path(1);
            tmp.do_delete = 1;

        end

        function output = run_clean(obj, output)

            % clean up temporary directory if asked to do so
            if (~isstruct(output)), return; end
            
            if (isfield(output, 'tmp')) && ...
                    (isfield(output.tmp, 'do_delete')) && ...
                    (output.tmp.do_delete)

                msf_delete(output.tmp.bp);

            end
            
        end        
       
        % do not overload these
        function previous_outputs = get_iterable(obj)

            if (isempty(obj.previous_node))
                error('previous_node not defined, aborting');
            end

            % Merging needed? (I do not want the code here, but rather in
            % the main dp code, but let it be here for the moment)
            if (iscell(obj.previous_node))

                list_of_outputs = cell(size(obj.previous_node));
                node_names = cell(size(list_of_outputs));

                for c = 1:numel(list_of_outputs)
                    node_names{c} = obj.previous_node{c}.name;
                    list_of_outputs{c} = obj.previous_node{c}.run(obj.opt.iter_mode, obj.opt);
                end

                f4 = @(x,y) max([1 1 + find(x == y, 1, 'first')]);
                f3 = @(x) x(f4(x,'_'):end);
                f2 = @(x) f3(x(f4(x,'/'):end));
                f1 = @(x) f2(char(x));
                list_of_prefixes = cellfun(@(x) f1(x), node_names, 'UniformOutput',false);

                if (numel(list_of_prefixes) ~= numel(unique(list_of_prefixes)))
                    error('merging previous nodes requires unique node names');
                end

                previous_outputs = dp_item.merge_outputs(list_of_outputs, list_of_prefixes);

                % report on outcome
                obj.log('--> Merging outputs (%s) resulted in %i items', ...
                    obj.join_cell_str(list_of_prefixes), ...
                    numel(previous_outputs));

            else % assume it is a dp_node

                previous_outputs = obj.previous_node.run(obj.opt.iter_mode, obj.opt);

            end

        end

        % run on all outputs from the previous node
        function outputs = run(obj, mode, opt)
            
            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), opt.present = 1; end
            if (ischar(opt) && strcmp(opt, 'debug')), opt = struct('do_try_catch', 0); end

            % set mode
            obj.mode = mode;

            % deal with options
            obj.opt.present = 1;
            opt = dp.dp_opt(opt);
            opt = obj.get_dpm().dp_opt(opt);

            % make sure this and previous nodes have names
            obj.update_node(opt);

            if (iscell(obj.previous_node))
                for c = 1:numel(obj.previous_node)
                    obj.previous_node{c}.update_node();
                end
            elseif (~isempty(obj.previous_node))
                obj.previous_node.update_node();
            end       


            outputs = dp.run(obj);
        end

        function obj = update_node(obj, opt) % set necessary properties

            if (isempty(obj.name))
                obj.name = class(obj);
            end

            if (nargin > 1)
                obj.opt = opt;
            end
        end

        function modes = get_supported_modes(obj)
            modes = cellfun(@(x) x.get_mode_name(), obj.dpm_list, 'UniformOutput', false);
        end

        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end

        % run the data processing mode's processing/reporting
        function outputs = process_outputs(obj, outputs)
            obj.get_dpm().process_outputs(outputs);
        end
       
        function pop = manage_po(obj, pop)
            if (~msf_isfield(pop, 'id')), error('id field missing'); end
        end

        % compute input to this node from previous output
        function input = run_po2i(obj, pop, varargin)
            
            input = obj.po2i(pop);

            % transfer id, output path, base path, if they exist
            f = {'id', 'op', 'bp'};
            for c = 1:numel(f)
                if (isfield(pop, f{c}) && ~isfield(input, f{c}))
                    input.(f{c}) = pop.(f{c});
                end
            end

        end

        % compile output
        function output = run_i2o(obj, input)
            output = obj.i2o(input);

            f = {'id', 'op', 'bp'};

            if (obj.do_i2o_pass) % pass all inputs to outputs
                f = cat(2, fieldnames(input));
            end

            for c = 1:numel(f)
                if (isfield(input, f{c}) && ~isfield(output, f{c}))
                    output.(f{c}) = input.(f{c});
                end
            end
            
        end

        % dpm - data processing mode (e.g. report, iter, debug, execute...)
        function dpm = get_dpm(obj, mode)

            if (nargin < 2), mode = obj.mode; end
            
            ind = cellfun(@(x) strcmp(mode, x.get_mode_name()), obj.dpm_list);

            ind = find(ind);

            if (numel(ind) > 0)
            
                dpm = obj.dpm_list{ind};
            
            else % dpm not supported, but allow passthrough for workflows
                
                if (obj.do_dpm_passthrough)
                    dpm = dpm_passthrough(obj);
                else
                    error('mode (%s) not supported', obj.mode);
                end

            end

        end


        function ages = input_age(obj, input)
            ages = [];
        end

        function output_age(obj, output)
            ages = [];
        end

        function log(obj, varargin)

            % this function has evolved over time, so it is a little messy
            %
            % intended input format is this:
            % log level
            % string to fprintf
            % arguments

            % if first argument is string, then assume a log level
            if (all(ischar(varargin{1})))
                log_level = 1;
                varargin = cat(2, log_level, varargin);
            end

            if (numel(varargin) < 2), varargin{2} = ''; end
            if (numel(varargin) < 3), varargin{3} = ''; end

            log_level = varargin{1};
            log_str = varargin{2};
            log_arg = varargin(3:end);

            if (obj.opt.verbose >= log_level)
                fprintf(cat(2, log_str, '\n'), log_arg{:});
            end

        end



    end

    methods (Hidden)

        % now duplicated
        function str = join_cell_str(f)

            g = @(x) x(1:(end-3));
            
            str = g(cell2mat(cellfun(@(x) cat(2, x, ' / '), f, ...
                'UniformOutput', false)));
        end
        
    end

 
    

end