classdef dp_node_base < dp_node_core & dp_node_base_support

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

        % run deep, experiment
        function outputs = run_deep(obj, mode, opt)
            opt.deep_mode = 1;
            outputs = obj.run(mode, opt);
        end

        % run on all outputs from the previous node
        function outputs = run(obj, mode, opt)
            
            if (nargin < 2), mode = 'report'; end
            if (nargin < 3), opt.present = 1; end

            % update options and mode of this node
            obj.update(opt, mode);

            % Report on status and init
            obj.log(0, '%tRunning %s with mode ''%s''', obj.name, obj.mode);

            % Retreive previous outputs
            previous_outputs = obj.get_iterable();
            
            if (isempty(previous_outputs))
                obj.log(0, '%tNo output from previous node - no actions will be taken!');
                outputs = {};
                return;
            elseif (strcmp(obj.mode, 'iter_deep')) % mode still used?
                outputs = previous_outputs;
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

            function err_log_fun(me, id)
                obj.log(0, '%s:   Error in node %s (mode: %s)', id, obj.name, obj.mode);
                obj.log(0, '%s:     %s', id, me.message);
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
                obj.log(0, '\nOperation took %1.1f seconds\n', toc);
            end
            
        end

        function previous_outputs = get_iterable(obj)

            if (isempty(obj.previous_node))
                error('%s: previous_node not defined, aborting', obj.name);
            end

            if (obj.opt.deep_mode)
                previous_outputs = obj.previous_node.get_iterable();
            else
                previous_outputs = obj.previous_node.run(obj.opt.iter_mode, obj.opt);
            end

        end

        function output = run_inner(obj, po)


            % In deep mode, we get the po by recursively running deeper
            if (obj.opt.deep_mode) && (~isempty(obj.previous_node))
                po = obj.previous_node.run_inner(po);
            end

            % Excessive logging with verbose level 2
            obj.log(2, '\nStarting %s', obj.name);

            % Build input and output
            [input, output] = obj.run_po2io(po);

            % Run and clean
            obj.log(5, '\noutput (declared):\n%s', formattedDisplayText(output));            
            
            output = obj.run_on_one(input, output);
            output = obj.run_clean(output);
            
            obj.log(2, '\noutput (after clean):\n%s', formattedDisplayText(output));

        end

        % previous output to output (of the present node)
        function [input, output] = run_po2io(obj, po) 

            obj.log(3, '\nprevious_output:\n%s', formattedDisplayText(po));

            % Previous output to a new input
            input = obj.run_po2i(po);
            obj.test_input(input);

            % Build output
            obj.log(3, '\ninput:\n%s', formattedDisplayText(input));
            output = obj.run_i2o(input);
        end

        function pop = manage_po(obj, pop)
            if (~msf_isfield(pop, 'id')), error('id field missing'); end
        end

        % compute input to this node from previous output
        function input = run_po2i(obj, pop, varargin)

            if (~isfield(pop, 'id')), error('id field missing'); end
            
            input = obj.po2i(pop);

            % transfer id, output path, base path, if they exist
            f = {'id', 'op', 'bp'};
            for c = 1:numel(f)
                if (isfield(pop, f{c}) && ~isfield(input, f{c}))
                    input.(f{c}) = pop.(f{c});
                end
            end

        end

        % tests for required input fields (helps debugging)
        % here we do not test whether files exist, only if the fields
        % are in place -- to make debugging easier
        function test_input(obj, input)

            f = unique(cat(2, obj.input_test, obj.input_fields));
            tmp = {};
            
            % test for missing fields
            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    tmp{end+1} = f{c}; %#ok<AGROW>
                end
            end

            if (~isempty(tmp))

                error('input fields missing (%s) for node %s', ...
                    strjoin(tmp, ', '), obj.name)
                
            end
        end

        % compile output
        function output = run_i2o(obj, input)

            % check quality of input
            f = {'id', 'bp'}; % op not needed at all times

            for c = 1:numel(f)
                if (~isfield(input, f{c}))
                    % xxx: better solution needed
                    obj.log(0, 'Mandatory input field missing (%s) in node %s', f{c}, obj.name);
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
        
        % allow this to be called by e.g. the execute method
        function outputs = execute_on_outputs(obj, outputs)
            1;
        end
       
    end        

end
