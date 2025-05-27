classdef dp_node_core_run_fun < ...
        dp_node_core_central & ...
        dp_node_core_log & ...
        handle

    % methods to support the running of nodes
    % but that are not crucial for the logic

    properties (Abstract)
        name;
    end

    properties
        do_i2o_pass = 0;
    end
    

    methods

        function [output, err] = run_fun(~, fun, err_log_fun, do_try_catch)

            if (~do_try_catch) % normal run

                output = fun();
                err = [];
                return;

            else % catch errors

                try

                    output = fun();
                    err = [];
                    return;

                catch me

                    err_log_fun(me);
                    output = [];
                    err = me;

                end
            end

        end


        function analyze_output(obj, previous_outputs, outputs, errors)

            do_show_first_error = 0;

            % Check if we're missing outputs because of an error 
            % (do generous logging)
            if (numel(outputs) == 0) && (numel(previous_outputs) > 0)

                obj.log(0, '');
                obj.log(0, 'This node (%s) produced no outputs', obj.name);
                obj.log(0, '  despite having outputs to process from the previous node');

                if (numel(errors) == 0)
                    obj.log(0, '  and no errors occurred during processing - unexpected!');
                else
                    obj.log(0, '  probably beacuse one or more errors occurred.');
                    
                    do_show_first_error = 1;

                end
 
            elseif (numel(errors) > 0)

                obj.log(0, '%tNote: %i errors occurred (%i valid outputs out of %i previous outputs)', ...
                    numel(errors), numel(outputs), numel(previous_outputs));
                
            end

            % Log level (make it visible at level 0 if requested)
            l = 1;

            if (do_show_first_error), l = 0; end

            if (numel(errors) > 0)
                obj.log(l, ' ');
                obj.log(l, '  First error:');
                obj.log(l, ' ');
                obj.log(l, '<a href="matlab: opentoline(''%s'', %d)">%s</a>', errors{1}.stack(1).file, errors{1}.stack(1).line, errors{1}.message);
                obj.log(l, ' ');
                obj.log(l, '%s', formattedDisplayText(errors{1}.stack(1)));
                obj.log(l, ' ');
            end
        
        end        
        
        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end

        % for overloading
        function outputs = process_outputs(~, outputs)
            1; 
        end
       
        function pop = manage_po(~, pop)
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

    end

end