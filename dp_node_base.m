classdef dp_node_base < dp_node_base_support

    % this should really be named "run manager", as this
    % class implements functions related to running nodes
    %
    % this should include all logic, while the helper functions are in 
    % the support class

    properties
        opt;
        do_i2o_pass = 0;
    end

    methods

        % run on all outputs from the previous node
        function outputs = run(obj, mode, opt)
            
            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), opt.present = 1; end

            % update options and mode of this node
            obj.update(opt, mode);

            % Report on status and init
            obj.log(0, '%tRunning %s with mode ''%s''', obj.name, obj.mode);

            % Retreive previous outputs
            previous_outputs = obj.filter_iterable(obj.get_iterable());
            
            if (isempty(previous_outputs))
                obj.log(0, '%tNo output from previous node - no actions will be taken!');
                return;
            elseif (strcmp(obj.mode, 'iter_deep'))
                outputs = previous_outputs;
                return;
            end

            % Loop over all previous outputs
            if (obj.opt.c_level == 1)
                obj.log(0, '\nStarting iterations for mode: %s\n', obj.mode);
            end

            outputs = cell(size(previous_outputs));
            err_list = cell(size(previous_outputs));

            function err_log_fun(me, id)
                obj.log(2, '%s: Error in node %s (mode: %s)', id, obj.name, obj.mode);
                obj.log(2, '%s:   %s', id, me.message);
            end
            
            for c = 1:numel(previous_outputs)

                obj.log(2, '-------------------');
                obj.log(1, 'Running %s for %s', obj.name, previous_outputs{c}.id)
                obj.log(2, '-------------------');

                % Run in a try-catch environment, if asked for
                [outputs{c}, err_list{c}] = obj.run_fun(...
                    @() obj.run_inner(previous_outputs{c}), ...
                    @(me) err_log_fun(me, previous_outputs{c}.id));

                obj.log(1, ' ');
            end

            % Trim
            f = @(x) x(cellfun(@(y) ~isempty(y), x));
            outputs = f(outputs);
            err_list = f(err_list);

            % Wrap up with some reporting
            obj.analyze_output(previous_outputs, outputs, err_list);
            outputs = obj.process_outputs(outputs);             
        end

        function previous_outputs = get_iterable(obj)

            if (isempty(obj.previous_node))
                error('%s: previous_node not defined, aborting', obj.name);
            end

            previous_outputs = obj.previous_node.run(obj.opt.iter_mode, obj.opt);

        end

        function output = run_inner(obj, po)

            % Excessive logging with verbose level 2
            obj.log(2, '\nStarting %s', obj.name);

            % Manage previous output
            po = obj.manage_po(po);
            obj.log(3, '\nprevious_output:\n%s', formattedDisplayText(po));

            % Previous output to a new input
            input  = obj.run_po2i(po, obj.get_dpm().do_input_check);
            obj.log(3, '\ninput:\n%s', formattedDisplayText(input));

            % Run the processing, and display output
            output = obj.run_i2o(input);
            output = obj.run_on_one(input, output);
            output = obj.run_clean(output);
            obj.log(2, '\noutput:\n%s', formattedDisplayText(output));

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

            % check quality of input
            f = {'id', 'bp'}; % op not needed at all times

            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    % xxx: better solution needed
                    obj.log(0, 'Mandatory input field missing (%s)', f{c});
                    error('Mandatory input field missing (%s)', f{c});
                end
            end

            output = obj.i2o(input);

            % check quality of input
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

        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
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
        
        % run the data processing mode's processing/reporting
        function outputs = process_outputs(obj, outputs)
            outputs = obj.get_dpm().process_outputs(outputs);
        end
       
    end        

    methods (Static)

        function opt = default_opt(opt)
            
            opt = msf_ensure_field(opt, 'verbose', 0);
            opt = msf_ensure_field(opt, 'do_try_catch', 1);
            opt = msf_ensure_field(opt, 'id_filter', {});
            opt = msf_ensure_field(opt, 'iter_mode', 'iter');

            % do not write over existing data as per default
            opt = msf_ensure_field(opt, 'do_overwrite', 0);
            
            opt = msf_ensure_field(opt, 'c_level', 0);
            opt.c_level = opt.c_level + 1;

            opt.indent = zeros(1, 2*(opt.c_level - 1)) + ' ';

            opt = msf_ensure_field(opt, 'id_filter', {});

            if (ischar(opt.id_filter))
                opt.id_filder = {opt.id_filter};
            end
        end

    end

end