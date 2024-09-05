classdef dpm_report < dpm

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'report';
        end
        

        function opt = dp_opt(obj, opt)
            opt.verbose = 1;
        end

        function output = run_on_one(obj, input, output, opt)

            % report on the existance of files
            input_status = obj.node.input_exist(input);
            output_status = obj.node.output_exist(output);


            % build and print string
            str = input.id;

            for c = 1:numel(input_status)
                str = sprintf('%s\t%s', str, 'N' + input_status(c) * ('Y' - 'N'));
            end

            str = sprintf('%s\t-->', str);            

            for c = 1:numel(output_status)
                str = sprintf('%s\t%s', str, 'N' + output_status(c) * ('Y' - 'N'));
            end

            opt.log(str);


            % check if we are done (used below)
            if (all(output_status))
                output.status = 'done';
            end        
            
        end

        function process_outputs(obj, outputs, opt)

            % Count number of done's
            f = @(x) isfield(x, 'status') && (strcmp(x.status, 'done'));
            n_done = sum(cellfun(f, outputs));

            opt.log('\nStatus: %i done (all outputs is Y) out of %i possible', ...
                n_done, numel(outputs));

            if (numel(outputs) > 0) % xxx: show inner structs better
                disp(' ');
                disp('Example of output structure');
                disp(outputs{1});
            end

        end

    end

end