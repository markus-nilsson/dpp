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

            if (~all(obj.node.output_exist(output)))
                obj.node.opt.log(1, 'Output not a valid iter item for next node');
            end
            
        end

        function process_outputs(obj, outputs)

            % Consider re/implementing some reporting here
            1;

        end

    end

end