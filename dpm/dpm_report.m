classdef dpm_report < dpm

    methods

        function mode_name = get_mode_name(~)
            mode_name = 'report';
        end       

        function opt = dp_opt(~, opt)
            1;
        end

        function output = run_on_one(obj, input, output)
                       
            % report on the existence of files
            [input_status, input_f] = obj.node.input_exist(input);
            [output_status, output_f] = obj.node.output_exist(output);

            % build and print string
            str = '';

            for c = 1:numel(input_status)
                str = sprintf('%s\t%s', str, 'N' + input_status(c) * ('Y' - 'N'));
            end

            str = sprintf('%s\t-->', str);            

            for c = 1:numel(output_status)
                str = sprintf('%s\t%s', str, 'N' + output_status(c) * ('Y' - 'N'));
            end

            obj.node.log(0, '%s\t%s', input.id, str);

            obj.node.log(2, '\ninput fields:\n');
            obj.node.log(2, '%s', formattedDisplayText(input_f));
            obj.node.log(2, '\noutput fields:\n');
            obj.node.log(2, '%s', formattedDisplayText(output_f));
            

            % check if we are done (used below)
            if (all(output_status))
                output.status = 'done';
            end        
            
        end

        function outputs = process_outputs(obj, outputs)

            % Count number of done's
            f = @(x) isfield(x, 'status') && (strcmp(x.status, 'done'));
            n_done = sum(cellfun(f, outputs));

            obj.node.log(0, '\nStatus: %i done (all outputs is Y) out of %i possible', ...
                n_done, numel(outputs));

            if (numel(outputs) > 0) % xxx: show inner structs better
                disp(' ');
                disp('Example of output structure');
                disp(outputs{1});
            end

        end

    end

end