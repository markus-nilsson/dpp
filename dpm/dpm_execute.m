classdef dpm_execute < dpm

    properties
        do_run_execute = 1;
        do_date_check = 1;
    end

    methods

        function obj = dpm_execute(node)
            obj = obj@dpm(node);
            obj.do_run_on_all_in_workflow = 1;
            obj.err_log_level = 0;
        end

        function mode_name = get_mode_name(obj)
            mode_name = 'execute';
        end

        function opt = dp_opt(obj, opt)            
            opt = msf_ensure_field(opt, 'verbose', 1);
        end

        function do_run = do_run_node(obj, input, output)

            % if the node wants to overwrite even though the options says
            % no, it will have to delete the output on its own

            % xxx: think this through
            % % not sure this is how we should do it, but let's try
            % output = msf_ensure_field(output, 'opt', struct('present', 1));
            % output.opt = msf_ensure_field(output.opt, 'do_overwrite', 0);
            %
            % if (output.opt.do_overwrite)
            %     opt.do_overwrite = output.opt.do_overwrite;
            % end

            % default is to run
            do_run = 1; 

            if (obj.node.opt.do_overwrite)
                obj.node.log(1, '%s:   opt.do_overwrite is true', input.id);
                return;
            end
                        
            % also check for age of output relative to input!
            % xxx: this does not work very well for copied files, as this
            %      preserves the creation date of the original file
            [outputs_exist,f_output,output_age] = obj.node.output_exist(output);
            [inputs_exist,f_input,input_age] = obj.node.input_exist(input);

            % input missing?
            if (~isempty(inputs_exist)) && (~all(inputs_exist))
                f_input = f_input(~inputs_exist);
                error('Input files missing: %s (in node %s)', ...
                    strjoin(f_input, ', '), obj.node.name);
            end
            

            % output missing?
            if (~isempty(outputs_exist)) && ~(all(outputs_exist))
                obj.node.log(1, '%s:   Outputs missing', input.id);                
                return;
            end

            % input and outputs missing (non-file node assumed)
            if (isempty(outputs_exist))
                obj.node.log(1, '%s:   Empty outputs, assuming non-file node', input.id);                
                return;
            end

            
            % check ages
            if (~isempty(input_age) && ~isempty(output_age)) && (obj.do_date_check)

                [min_output_age, output_ind] = nanmin(output_age);
                [max_input_age, input_ind] = nanmax(input_age);

                all_outputs_are_younger = min_output_age >= max_input_age;

                if (~all_outputs_are_younger)

                    obj.node.log(0, '%s:   Old outputs detected, overwriting', input.id);

                    obj.node.log(1, '%s:     %s (in: %s)', input.id, datestr(max_input_age), f_input{input_ind});
                    obj.node.log(1, '%s:     %s (out: %s)', input.id, datestr(min_output_age), f_output{output_ind});

                    return;
                end
            end
            
            % Found no reason to run
            do_run = 0; 
        end

        function output = run_on_one(obj, input, output)

            obj.node.log(0, '%s: Starting mode ''execute'' on node %s', input.id, obj.node.name);
            output.execute.status = 'Skip';

            if (~obj.do_run_execute)
                obj.node.log(1, '%s:   No action needed', input.id); 
                return;
            end

            obj.node.log(1, '%s:   Testing execute conditions', input.id);

            if (obj.do_run_node(input, output))                
                obj.node.log(1, '%s:   Starting execution...', input.id);
                output.execute.status = 'Error';
                t0 = tic;
                output = obj.node.execute(input, output);            
                output.execute.status = 'Executed';
                output.execute.t = toc(t0);
                obj.node.log(0, '%s:   Done executing %s', input.id, obj.node.name);
            else
                obj.node.log(0, '%s:   Found no reason to execute', input.id);
            end
                        
        end

        function outputs = process_outputs(obj, outputs)
            outputs = obj.node.execute_on_outputs(outputs);


            % Find those which were executed
            f = @(s) cellfun(@(x) strcmp(x.execute.status, s), outputs);
            ind_exe = f('Executed');
            ind_err = f('Error');
            ind_skip = f('Skip');

            % Compute times and numbers
            n_errors   = sum(ind_err);
            n_skipped  = sum(ind_skip);
            n_executed = sum(ind_exe);

            t_total = sum(cellfun(@(x) x.execute.t, outputs(ind_exe)));
            t_per_item = t_total / n_executed;

            % Log it
            f = @(t) dpm_execute.time2str(t);

            if (n_executed == 0) && (n_errors == 0)

                obj.log(0, '\nAll done (%i items already done)', n_skipped);

            elseif (n_executed == 0) && (n_error > 0)

                obj.log(0, '\nAll done (%i items done already, %i errors)', ...
                    n_skipped, n_errors);

            else

                obj.log(0, '\nOperation took %s in total, %s per item (%i items done, %i skipped, %i errors)', ...
                    f(t_total), f(t_per_item), n_executed, n_skipped, n_errors);

            end

            
        end

    end

    methods (Static)

        function s = time2str(t)
            if (t < 60)
                s = sprintf('%1.1f seconds', t);
            elseif (t < 3600)
                s = sprintf('%1.1f minutes', t/60);
            elseif (t < 3600*24)
                s = sprintf('%1.1f hours', t/60/60);
            else
                s = sprintf('%1.1f days', t/60/60/24);
            end
        end

    end

end