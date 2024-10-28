classdef dpm_debug < dpm_execute

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'debug';
        end

        function opt = dp_opt(obj, opt)
            opt.do_try_catch = 0;
            opt.verbose = 3;
        end

    end

end