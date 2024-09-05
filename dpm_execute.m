classdef dpm_execute < dpm

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'execute';
        end

        function opt = dp_opt(opt)
            opt.verbose = 1;
        end

        function output = run_on_one(obj, input, output, opt)

            opt = msf_ensure_field(opt, 'do_overwrite', 0);

            % not sure this is how we should do it, but let's try
            output = msf_ensure_field(output, 'opt', struct('present', 1));
            output.opt = msf_ensure_field(output.opt, 'do_overwrite', 0);

            if (output.opt.do_overwrite)
                opt.do_overwrite = output.opt.do_overwrite;
            end
            
            outputs_exist = obj.node.output_exist(output);

            if (all(outputs_exist)) && (~opt.do_overwrite)
                if (opt.verbose), disp('All outputs exist, skipping'); end
                return;
            end

            if (opt.verbose), opt.log('Processing: %s', input.id); end

            output = obj.node.execute(input, output);            
                        
        end

        function process_outputs(obj, outputs, opt)

            1;

        end

    end

end