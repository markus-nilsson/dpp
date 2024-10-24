classdef dp % data processor

    % we are working with input and output structures, with some rules
    % embedded here

    % fields that are expected of the input and output structures
    %
    % id - uniquely defines a subject or subject/date
    % bp - base path
    % *_fn - filenames, will be checked if they exist
    %
    % in addition, it could have these field(s):
    %
    % tmp - temporary info, with fields
    %   bp - base path
    %   do_delete - determines whether the path will be deleted after
    %   execution


    % to dos: add name filtering, enable options pass-through


    methods (Static)

        function outputs = run(node)
            
            % Report on status
            node.log('Running %s with mode ''%s''', node.name, node.mode);

            % Run previous steps first to get items to iterate over
            previous_outputs = node.get_iterable();

            node.log('Found %i candidate items', numel(previous_outputs));

            % Filter and exclude items
            previous_outputs = dp_item.exclude(previous_outputs, node.opt);
            previous_outputs = dp_item.filter(previous_outputs, node.opt);

            % Check before we move on
            if (numel(previous_outputs) == 0)
                node.log('Iteration list empty - no actions will be taken!');
                outputs = {};
                return;
            end

            % Run iterations, save outputs
            if (node.opt.c_level == 1)
                node.log('\nStarting iterations for mode: %s\n', node.mode);
            end

            n = struct('input', 0, 'output', 0, 'run', 0);
            n.previous_outputs = numel(previous_outputs);         

            % Loop over all previous outputs
            outputs = {};

            function output = inner_fun(po)
                po     = node.manage_po(po);
                input  = node.run_po2i(po);
                output = node.run_i2o(input);
                output = node.run_on_one(input, output);
                output = node.run_clean(output);
            end  
            
            for c = 1:numel(previous_outputs)

                po = previous_outputs{c};

                if (node.opt.do_try_catch)

                    try

                        outputs{end+1} = inner_fun(po); %#ok<AGROW>

                    catch me

                        % Deal with error
                        [error_source, n] = dp.deal_with_errors(me, n);

                        if (node.opt.verbose) || (strcmp(node.mode, 'report'))
                            fprintf('%s --> %s (%s)\n', previous_outputs{c}.id, ...
                                me.message, error_source);
                        end
                    end
                else
                    outputs{end+1} = inner_fun(po); %#ok<AGROW>
                end
            end

            % Wrap up with some reporting
            outputs = node.process_outputs(outputs); 

        end


        function [error_source, n_errors] = deal_with_errors(me, n_errors)

            
            f = @(x) x( (find(x == '.')+1) : end);

            c_match = -1;
            pattern = 'dp.run';
            for c = 1:numel(me.stack)
                if (strcmp(me.stack(c).name(1:min(end,numel(pattern))), pattern))
                    c_match = c;
                    break;
                end
            end
            c_match = c_match - 1;

            if (c_match > 0)
                error_source = f(me.stack(c_match).name);
            else
                error_source = 'internal';
            end

            switch (error_source)

                case 'manage_po'
                    error('should not happen (%s)', me.message);
                case 'run_po2i'
                    n_errors.input = n_errors.input + 1;
                case 'run_i2o'
                    n_errors.output = n_errors.output + 1;
                case 'run_fun'
                    n_errors.run = n_errors.run + 1;
                case 'run_on_one'
                    n_errors.run = n_errors.run + 1;
                case 'run_clean'
                    n_errors.run = n_errors.run + 1;
                otherwise
                    disp('----------');
                    disp(error_source);
                    disp('----------');

                    rethrow(me);
            end
        
        end


        function opt = dp_opt(opt)
            
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