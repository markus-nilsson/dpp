classdef dpm_execute < dpm

    methods

        function obj = dpm_execute(node)
            obj = obj@dpm(node);
            obj.do_run_on_all_in_workflow = 1;
        end

        function mode_name = get_mode_name(obj)
            mode_name = 'execute';
        end

        function opt = dp_opt(obj, opt)
            opt.verbose = 1;
        end

        function output = run_on_one(obj, input, output)


            % if the node wants to overwrite even though the options says
            % no, it will have to delete the output on its own

            % % not sure this is how we should do it, but let's try
            % output = msf_ensure_field(output, 'opt', struct('present', 1));
            % output.opt = msf_ensure_field(output.opt, 'do_overwrite', 0);
            % 
            % if (output.opt.do_overwrite)
            %     opt.do_overwrite = output.opt.do_overwrite;
            % end
            
            % also check for age of output relative to input! 
            % xxx: this does not work very well for copied files, as this
            %      preserves the creation date of the original file
            [outputs_exist,f_output,output_age] = obj.node.output_exist(output);
            [inputs_exist,f_input,input_age] = obj.node.input_exist(input);

            all_outputs_are_younger = 0;
            if 1 && ...
                    (~isempty(outputs_exist)) && (any(outputs_exist)) && ...
                    (~isempty(inputs_exist)) && (all(inputs_exist))
                    
                [min_output_age, output_ind] = nanmin(output_age);
                [max_input_age, input_ind] = nanmax(input_age);

                all_outputs_are_younger = min_output_age >= max_input_age;

                if (~all_outputs_are_younger)

                    obj.node.log('%s: Old outputs detected, overwriting', input.id);

                    if (obj.node.opt.verbose)
                        obj.node.log('%s: %s (in: %s)', input.id, datestr(max_input_age), f_input{input_ind});
                        obj.node.log('%s: %s (out: %s)', input.id, datestr(min_output_age), f_output{output_ind});
                    end
                    
                end
            end

            if ...
                    (all(outputs_exist)) && ...
                    (~obj.node.opt.do_overwrite) && ...
                    (all_outputs_are_younger)
                
                if (obj.node.opt.verbose)
                    obj.node.log('%s: All outputs exist, skipping', input.id); 
                end
                return;
            end

            if (obj.node.opt.verbose)
                obj.node.log('%s: Processing', input.id); 
            end

            output = obj.node.execute(input, output);            
                        
        end

        function process_outputs(obj, outputs)
            1;
        end

    end


end