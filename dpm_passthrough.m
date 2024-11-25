classdef dpm_passthrough < dpm

    % does nothing, just allows a passthrough

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'passthrough';
        end
        
        function opt = dp_opt(obj, opt)
            opt.present = 1;
        end

        function output = run_on_one(obj, input, output)
            1;
        end

        function process_outputs(obj, outputs)
            1;
        end


    end
end