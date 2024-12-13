classdef dp_node_base_support < dp_node_core

    % methods to support the running of nodes
    % but that are not crucial for the logic


    methods

        function obj = update(obj, opt, mode) % set necessary properties

            if (isempty(obj.name)), obj.name = class(obj); end

            if (nargin < 2), opt.present = 1; end
            if (nargin < 3), mode = obj.mode; end

            % set mode first
            obj.mode = mode;            
           
            obj.opt = dp_node_base.default_opt(opt);

            if (~isempty(obj.mode))
                obj.opt = obj.get_dpm().dp_opt(obj.opt);
            end

            % force outside do_try_catch
            if (isfield(opt, 'do_try_catch'))
                obj.opt.do_try_catch = opt.do_try_catch;
            end

            % Report options
            obj.log(3, 'Options: %s', formattedDisplayText(obj.opt));

            % set log options
            obj.log_opt.verbose = obj.opt.verbose;
            obj.log_opt.c_level = obj.opt.c_level;

            % not sure if this is always a good idea, but let us try it
            if (~isempty(obj.previous_node)) && (obj.opt.deep_mode)
                obj.previous_node.do_dpm_passthrough = 1;                
                obj.previous_node.update(obj.opt, mode);
            end

        end  

        function previous_outputs = filter_iterable(obj, previous_outputs)

            obj.log(0, '%tFound %i candidate items', numel(previous_outputs));            
            
            % one of these functions that are here to make life easier
            % but that should not have to be here if things were 
            % done correctly from the start
            if (isa(obj.previous_node, 'dp_node_primary'))
                ind = ones(size(previous_outputs));
                for c = 1:numel(ind)
                    if (previous_outputs{c}.id(1) == '.')
                        ind(c) = 0;
                    end
                end
                previous_outputs = previous_outputs(ind == 1);
                obj.log(2, '%tCleaned %i bad items', sum(ind == 0));                
            end

            % Filter and exclude items
            previous_outputs = dp_item.exclude(previous_outputs, obj);
            previous_outputs = dp_item.filter(previous_outputs, obj);

        end
     
        function [output, err] = run_fun(obj, fun, err_log_fun, do_try_catch)

            if (nargin < 4), do_try_catch = obj.opt.do_try_catch; end

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
                    obj.log(0, ' ');
                    obj.log(0, '  First error:');
                    obj.log(0, ' ');
                    obj.log(0, '<a href="matlab: opentoline(''%s'', %d)">%s</a>', errors{1}.stack(1).file, errors{1}.stack(1).line, errors{1}.message);
                    obj.log(0, ' ');
                    obj.log(0, '%s', formattedDisplayText(errors{1}.stack(1)));
                    obj.log(0, ' ');

                end
 
            elseif (numel(errors) > 0)

                obj.log(0, '%tNote: %i errors occurred (%i valid outputs out of %i previous outputs)', ...
                    numel(errors), numel(outputs), numel(previous_outputs));
                
            end
        
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
        
        % run the data processing mode's function here
        function output = run_on_one(obj, input, output)
            output = obj.get_dpm().run_on_one(input, output);
        end

        % run the data processing mode's processing/reporting
        function outputs = process_outputs(obj, outputs)
            outputs = obj.get_dpm().process_outputs(outputs);
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

    end

    methods (Static)

        function opt = default_opt(opt)
            
            opt = msf_ensure_field(opt, 'verbose', 0);
            opt = msf_ensure_field(opt, 'do_try_catch', 1);
            opt = msf_ensure_field(opt, 'id_filter', {});
            opt = msf_ensure_field(opt, 'iter_mode', 'iter');

            opt = msf_ensure_field(opt, 'deep_mode', 0);
            
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