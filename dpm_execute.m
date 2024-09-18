classdef dpm_execute < dpm

    methods

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
            [outputs_exist,~,output_age] = obj.node.output_exist(output);
            [inputs_exist,~,input_age] = obj.node.input_exist(input);

            all_outputs_are_younger = 0;
            if (any(outputs_exist)) && (all(inputs_exist))

                all_outputs_are_younger = nanmin(output_age) > nanmax(input_age);

                if (~all_outputs_are_younger)

                    if (obj.node.opt.verbose)
                        obj.node.log('%s: %s vs %s', input.id, ...
                            datestr(nanmin(output_age)), datestr(nanmax(input_age)));
                    end

                    obj.node.log('%s: Old outputs detected, overwriting', input.id);
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