classdef dpm_iter < dpm

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'iter';
        end
        
        function opt = dp_opt(obj, opt)

            opt = msf_ensure_field(opt, 'verbose', 0);

            if (~isinf(opt.verbose))
                opt.verbose = 0; % force it to be off here unless in super verbose
            end

        end

        function output = run_on_one(obj, input, output)
            
            output.iter.output_exist = all(obj.node.output_exist(output));

            if (~output.iter.output_exist)
                obj.node.log(1, 'Output not a valid iter item for next node');
            end            
        end

        function outputs = process_outputs(obj, outputs)

            if (numel(outputs) == 0), return; end

            % Does not work for items, fix implementatin
            if (isfield(outputs{1}, 'items'))
                warning('not implemented');
                return;
            end

            % Consider re/implementing some reporting here
            ind = zeros(size(outputs));
            for c = 1:numel(outputs)
                ind(c) = outputs{c}.iter.output_exist;
                outputs{c} = msf_rmfield(outputs{c}, 'iter');
            end

            % Report
            if (sum(ind == 0) > 0)
                obj.node.log(0, '%tPruning %i of %i items, outputs missing', ...
                    sum(ind == 0), numel(ind));
            end

            % Prune
            outputs = outputs(ind == 1);

        end

    end

end