classdef dp_node_base < dp_node_core

    % this should really be named "run manager", as this
    % class implements functions related to running nodes
    %
    % support is implemented via the core methods

    properties
        input_spec;
    end
    

    methods 

        function obj = dp_node_base()
            s = dp_io_spec(obj);
            s.add('bp', 'path', 1, 1, 'Base path');
            s.add('id', 'string', 1, 0, 'Subject/session identifier');
            obj.input_spec = s;
        end

        function input_print(obj)
            obj.input_spec.print();
        end

        % run deep, experiment
        function outputs = run_deep(obj, mode, opt)
            if (nargin < 3), opt.present = 1; end
            opt.deep_mode = 1;
            outputs = obj.run(mode, opt);
        end

        % set mode and options, and run the node! 
        function outputs = run(obj, mode, opt)
            
            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), opt = []; end

            % Reset runtime options
            opt.run_id = datetime('now'); 
            obj.opt_runtime = opt;     

            % Run it using internal function!
            outputs = obj.i_run(mode);

        end
    end

    methods (Hidden) % internal functions

        % run on all outputs from the previous node
        function outputs = i_run(obj, mode)

            % Keep track of execution depth (for logging)
            obj.mode = mode;
            obj.c_level_plus();

            % Report on status, init, options
            obj.log(0, '%tRunning %s with mode ''%s''', obj.name, obj.mode);
            obj.log(3, 'Options: %s', obj.opt);

            % Retreive previous outputs
            previous_outputs = obj.filter_iterable(obj.get_iterable());
            
            if (isempty(previous_outputs))
                obj.log(0, '%tNo output from previous node - no actions will be taken!');
                outputs = {};
                return;
            else
                obj.log(0, '%tFound %i candidate items', numel(previous_outputs));   
            end

            % Loop over all previous outputs
            if (obj.opt.c_level == 1)
                obj.log(0, '\nStarting iterations for mode: %s\n', obj.mode);
                tic;
            end

            outputs = cell(size(previous_outputs));
            err_list = cell(size(previous_outputs));

            % Define error logging (xxx: not sure this is how we should do it)
            tmp_level = obj.get_dpm().err_log_level; 

            function err_log_fun(me, id)
                obj.log(tmp_level, '%t%s:   Error in node %s (mode: %s)', id, obj.name, obj.mode);
                obj.log(tmp_level, '%t%s:     %s', id, me.message);
            end

            for c = 1:numel(previous_outputs)

                obj.log(2, '%t-------------------');
                obj.log(1, '%tRunning %s for %s', obj.name, previous_outputs{c}.id)
                obj.log(2, '%t-------------------');

                % Run in a try-catch environment, if asked for
                [outputs{c}, err_list{c}] = obj.run_fun(...
                    @() obj.run_inner(previous_outputs{c}), ...
                    @(me) err_log_fun(me, previous_outputs{c}.id), ...
                    obj.opt.do_try_catch);

                obj.log(1, ' ');
            end

            % Trim by eliminating empty outputs
            f = @(x) x(cellfun(@(y) ~isempty(y), x));
            outputs = f(outputs);
            err_list = f(err_list);

            % Run the node's postprocessing
            outputs = obj.process_outputs(outputs);

            % Wrap up with some reporting (including from the dpm)
            obj.analyze_output(previous_outputs, outputs, err_list);
            outputs = obj.get_dpm().process_outputs(outputs);

            if (obj.opt.c_level == 1)
                t = toc;
                if (toc < 60)
                    obj.log(0, '\nOperation took %1.1f seconds\n', t);
                elseif (toc < 3600)
                    obj.log(0, '\nOperation took %1.1f minutes\n', t/60);
                elseif (toc < 3600*24)
                    obj.log(0, '\nOperation took %1.1f hours\n', t/60/60);
                else
                    obj.log(0, '\nOperation took %1.1f days\n', t/60/60/24);
                end
            end

            obj.c_level_minus();           
            
        end

        function previous_outputs = get_iterable(obj)
          
            if (isempty(obj.previous_node))
                error('%s: previous_node not defined, aborting', obj.name);
            end

            if (obj.opt.deep_mode)
                previous_outputs = obj.previous_node.get_iterable();
            else
                previous_outputs = obj.previous_node.i_run(obj.opt.iter_mode);
            end

        end

        function outputs = filter_iterable(obj, outputs)

            % Filtering demands we have a filter
            if (isempty(obj.opt.id_filter)), return; end

            % Match and keep matches
            status = dp_node_io_filter_by_id.match_filter(outputs, ...
                obj.opt.id_filter);

            outputs = outputs(status == 1);

        end        

        function output = run_inner(obj, po)

            % In deep mode, we get the po by recursively running deeper
            if (obj.opt.deep_mode) && (~isempty(obj.previous_node))
                obj.previous_node.mode = obj.mode;
                po = obj.previous_node.run_inner(po);
            end
            
            % Excessive logging with verbose level 2
            obj.log(2, '\nStarting %s', obj.name);

            % Build input and output
            [input, output] = obj.run_po2io(po);

            % Run and clean
            obj.log(5, '\noutput (declared):\n%s', output);            
            
            output = obj.run_on_one(input, output);
            output = obj.run_clean(output);
            
            obj.log(2, '\noutput (after clean):\n%s', output);

        end

        % previous output to output (of the present node)
        function [input, output] = run_po2io(obj, po) 

            obj.log(3, '\nprevious_output:\n%s', po);

            % Previous output to a new input
            input = obj.run_po2i(po);

            % Build output
            obj.log(3, '\ninput:\n%s', input);
            output = obj.run_i2o(input);
        end

        % compute input to this node from previous output
        function input = run_po2i(obj, pop, varargin)
           
            % Prepare input and trasfer key fields (gently)
            input = obj.po2i(pop);
            input = dp_input.copy(input, pop, {'id', 'op', 'bp'});
                
        end


        % compile output
        function output = run_i2o(obj, input)

            % check quality of input
            obj.input_spec.test(input, obj.input_test);

            output = obj.i2o(input);

            % transfer some input to output, optionally all fields
            f = {'id', 'op', 'bp'};            

            if (obj.do_i2o_pass) % pass all inputs to outputs
                f = cat(2, fieldnames(input));
            end

            output = dp_input.copy(output, input, f);
            
        end

        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end

        % allow this to be called by e.g. the execute method
        function outputs = execute_on_outputs(~, outputs)
            1;
        end
       
    end        

end
