classdef dpm_report_items < dpm

    properties
        maxlen = 0;
    end

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'report';
        end       

        function opt = dp_opt(obj, opt)
            1;
        end

        function output = run_on_one(obj, input, output)

            % report on the existance of files
            ostr = {}; tmp = {};
            for c = 1:numel(output.items)

                input_status = obj.node.inner_node.input_exist(input.items{c});
                output_status = obj.node.inner_node.output_exist(output.items{c});

                % build and print string
                tmp{1} = cat(2, input.id, ': ', input.items{c}.id);

                str = '';
                for c2 = 1:numel(input_status)
                    str = sprintf('%s\t%s', str, 'N' + input_status(c2) * ('Y' - 'N'));
                end

                str = sprintf('%s\t-->', str);

                for c2 = 1:numel(output_status)
                    str = sprintf('%s\t%s', str, 'N' + output_status(c2) * ('Y' - 'N'));
                end

                tmp{2} = str;

                ostr{end+1} = tmp;

            end

            maxlen = cellfun(@(x) numel(x{1}), ostr);

            if (isempty(maxlen))
                maxlen = 0;
            end

            obj.maxlen = max(obj.maxlen, max(maxlen));

            for c = 1:numel(ostr)
                obj.node.log(cat(2, pad(ostr{c}{1}, obj.maxlen+1, 'right'), ostr{c}{2}));
            end
            


            % check if we are done (used below)
            % if (all(output_status))
            %     output.status = 'done';
            % end        
            
        end

        function process_outputs(obj, outputs)

            % % Count number of done's
            % f = @(x) isfield(x, 'status') && (strcmp(x.status, 'done'));
            % n_done = sum(cellfun(f, outputs));
            % 
            % obj.node.log('\nStatus: %i done (all outputs is Y) out of %i possible', ...
            %     n_done, numel(outputs));

            if (numel(outputs) > 0) % xxx: show inner structs better
                disp(' ');
                disp('Example of output structure');
                disp(outputs{end});

                if (isfield(outputs{end}, 'items') && numel(outputs{end}.items) > 0)
                    disp(' ');
                    disp('Example of output structure');
                    disp(outputs{end}.items{1});
                end
            end

        end

    end

end