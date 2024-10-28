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


            % output missing?
            if (~isempty(outputs_exist)) && ~(all(outputs_exist))
                obj.node.log(1, '%s:   Outputs missing', input.id);                
                return;
            end

            % inputs missing? throw error
            if (~isempty(inputs_exist)) && ~(all(inputs_exist))
                error('inputs missing, should not happen');
            end

            % input and outputs missing (non-file node assumed)
            if (isempty(outputs_exist))
                obj.node.log(1, '%s:   Empty outputs, assuming non-file node', input.id);                
                return;
            end

            
            % check ages
            if (~isempty(input_age) && ~isempty(output_age))

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
            
            do_run = 0; 
            


        end

        function output = run_on_one(obj, input, output)

            obj.node.log(0, '%s: Starting mode ''execute'' on node %s', input.id, obj.node.name);
            obj.node.log(0, '%s:   Testing execute conditions', input.id);

            if (obj.do_run_node(input, output))                
                obj.node.log(0, '%s:   Starting execution...', input.id);
                output = obj.node.execute(input, output);            
                obj.node.log(0, '%s:   Done executing %s', input.id, obj.node.name);
            else
                obj.node.log(0, '%s:   Found no reason to execute', input.id);
            end
            
                        
        end

        function process_outputs(obj, outputs)
            1;
        end

    end


end