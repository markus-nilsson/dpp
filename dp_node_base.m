classdef dp_node_base < handle

    properties

        previous_node = [];

        name;
        mode;
        opt;
        log;

        dpm_list;

    end

    methods (Abstract)
        input_exist(obj, input);
        output_exist(obj, input);
    end

    methods

        function obj = dp_node_base()

            obj.dpm_list = {...
                dpm_iter(obj), ...
                dpm_execute(obj), ...
                dpm_debug(obj)};

            obj.log = @(varargin) fprintf(cat(2, '%s', varargin{1}, '\n'), ...
                opt.indent, varargin{2:end});

            obj.log = @(varargin) fprintf(cat(2, varargin{1}, '\n'), varargin{2:end});
            
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
                    node_names{c} = class(obj.previous_node{c});
                    list_of_outputs{c} = obj.previous_node{c}.run(obj.opt.iter_mode, obj.opt);
                end

                f4 = @(x,y) max([1 1 + find(x == y, 1, 'first')]);
                f3 = @(x) x(f4(x,'_'):end);
                f2 = @(x) f3(x(f4(x,'/'):end));
                f1 = @(x) f2(char(x));
                list_of_prefixes = cellfun(@(x) f1(x), node_names, 'UniformOutput',false);
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
            if (ischar(opt) && strcmp(opt, 'debug'))
                opt = struct('do_try_catch', 0);
            end

            obj.name = class(obj); % xxx
            obj.mode = mode;


            % deal with options
            obj.opt.present = 1;
            opt = dp.dp_opt(opt);
            opt = obj.get_dpm().dp_opt(opt);
            obj.opt = opt;          

            obj.log = @(varargin) fprintf(cat(2, '%s', varargin{1}, '\n'), ...
                obj.opt.indent, varargin{2:end});
            

            outputs = dp.run(obj);
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
        function input = run_po2i(obj, pop)
            input = obj.po2i(pop);
            input = msf_ensure_field(input, 'id', pop.id);
        end

        % compile output
        function output = run_i2o(obj, input)
            output = obj.i2o(input);
            output = msf_ensure_field(output, 'id', input.id);
        end

        % dpm - data processing mode (e.g. report, iter, debug, execute...)
        function dpm = get_dpm(obj, mode)

            if (nargin < 2)
                mode = obj.mode;
            end
            
            ind = cellfun(@(x) strcmp(mode, x.get_mode_name()), obj.dpm_list);

            ind = find(ind);

            if (numel(ind) == 0)
                error('mode (%s) not supported', obj.mode);
            end

            dpm = obj.dpm_list{ind};


        end


        function ages = input_age(obj, input)
            ages = [];
        end

        function output_age(obj, output)
            ages = [];
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