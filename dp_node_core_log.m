classdef dp_node_core_log < handle

    properties
        log_opt; 
    end

    methods

        function obj = dp_node_core_log()
            obj.log_opt.c_level = 0;
            obj.log_opt.verbose = 0;

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

            if (numel(varargin) < 2), varargin{2} = ''; end
            if (numel(varargin) < 3), varargin{3} = ''; end

            log_level = varargin{1};
            log_str = varargin{2};
            log_arg = varargin(3:end);


            if (obj.log_opt.verbose >= log_level)
                log_str = strrep(log_str, '%t', ...
                    char(zeros(1, max(0, 2*(obj.log_opt.c_level-1))) + ' '));
                fprintf(cat(2, log_str, '\n'), log_arg{:});
            end

        end

    end

end