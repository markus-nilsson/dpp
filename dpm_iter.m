classdef dpm_iter < dpm

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'iter';
        end
        
        function opt = dp_opt(opt)
            opt.verbose = 0; % force it to be off here
        end

        function output = run_on_one(obj, input, output, opt)

            if (~all(obj.node.output_exist(output)))
                error('Output missing, not a valid iter item');
            end
            
        end

        function process_outputs(obj, outputs, opt)

            % Consider re/implementing some reporting here
            1;

        end

    end

end