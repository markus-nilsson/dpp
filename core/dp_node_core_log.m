classdef dp_node_core_log < dp_node_core_opt & handle

    properties (Hidden)
        h_log_fn; % internal handle to log fn
    end

    properties
        log_fn;
    end


    methods

        function obj = dp_node_core_log()
            obj.h_log_fn = @(lvl, str, verbose) obj.print_log(lvl, str, verbose);
        end

        function log_fn = get.log_fn(obj)
            log_fn = obj.get_primary_node().h_log_fn;
        end

        function set.log_fn(obj, val)
            obj.get_primary_node().h_log_fn = val;
        end

        function log(obj, varargin)

            % this function has evolved over time, so it is a little messy
            %
            % intended input format is this:
            % log level
            % string to fprintf
            % arguments

            % if first argument is string, then assume a log level
            if (all(ischar(varargin{1})))
                log_level = 1;
                varargin = cat(2, log_level, varargin);
            end

            log_level = varargin{1};

            % Stop all formatting (which takes time) of logs that will
            % not be displayed
            if (obj.opt.do_log_early_stop) && (obj.opt.verbose < log_level)
                return;
            end
            

            if (numel(varargin) < 2), varargin{2} = ''; end
            if (numel(varargin) < 3), varargin{3} = ''; end

            log_str = varargin{2};
            log_arg = varargin(3:end);

            % Convert structs to strings
            for c = 1:numel(log_arg)
                if (isstruct(log_arg{c}))
                    log_arg{c} = formattedDisplayText(log_arg{c});
                end
            end

            % the first log_arg is usually the subject id, which we may
            % need to sanitize from \ on windows... but let's sanitize all
            % log arguments
            for c = 1:numel(log_arg)
                if (all(ischar(log_arg{c})))
                    log_arg{c} = strrep(log_arg{c}, '\', '/');
                end
            end

            log_str = strrep(log_str, '%t', ...
                char(zeros(1, max(0, 2*(obj.opt.c_level-1))) + ' '));
            
            log_str = sprintf(log_str, log_arg{:});


            % Send to log (replace with dynamic log management)
            obj.log_fn(log_level, log_str, obj.opt.verbose);

        end

        function print_log(obj, log_level, log_str, verbose)

            if (verbose >= log_level)
                fprintf(cat(2, log_str, '\n'));
            end

        end

    end

end