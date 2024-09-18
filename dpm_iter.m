classdef dpm_iter < dpm

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'iter';
        end
        
        function opt = dp_opt(obj, opt)
            opt.verbose = 0; % force it to be off here
        end

        function output = run_on_one(obj, input, output)

            if (~all(obj.node.output_exist(output)))
                if (obj.node.opt.verbose)
                    obj.node.opt.log('Output not a valid iter item for next node');
                end
            end
            
        end

        function process_outputs(obj, outputs)

            % Consider re/implementing some reporting here
            1;

        end

    end

end