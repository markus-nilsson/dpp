classdef dp_node_core_opt < ...
        dp_node_core_pipeline_manager & ...
        dp_node_core_dpm & ...
        handle

    % Manage options for the
    % - current execution (calling of 'run')
    %    - outside optoins
    %    - options provided by data processing mode
    % - node itself
    %
    % All these options are gently assembled into an options struct

    properties
    end
    
    properties (Hidden)
        opt_node = struct();
    end

    properties (Dependent)
        opt_runtime; 
        opt; % this is what the node will report
    end

    properties (Access = private) % default runtime opts
        opt_runtime_hidden = struct(...
            'c_level', 0, ...
            'verbose', 0, ...
            'do_try_catch', 1, ...
            'iter_mode', 'iter', ...
            'deep_mode', 0, ...
            'do_overwrite', 0, ...
            'id_filter', [], ...
            'do_log_early_stop', true, ... % internal use only
            'run_id', []);
    end

    methods

        function obj = dp_node_core_opt() 
            obj.opt_node.present = 1;
        end

        % Store/load the runtime opts in the primary node
        function set.opt_runtime(obj, opt)
            primary_node = obj.get_primary_node();
            old_opt = primary_node.opt_runtime;
            opt = obj.merge_opt(old_opt, opt); 
            primary_node.opt_runtime_hidden = opt; 
        end

        function opt = get.opt_runtime(obj)
            opt = obj.get_primary_node().opt_runtime_hidden;
        end
        
        % Keep track of how deeply we have recursed
        function obj = c_level_plus(obj)
            obj.opt_runtime.c_level = obj.opt_runtime.c_level + 1; 
        end

        function obj = c_level_minus(obj)
            obj.opt_runtime.c_level = obj.opt_runtime.c_level - 1;
        end

        function opt = get.opt(obj)

            % start with runtime opts
            try
                opt = obj.opt_runtime;
            catch
                warning('Primary node not found in %s', obj.name);
                opt = []; % will cause downstream erros, that's good
                return;
            end
                        
            if (~isempty(obj.mode))
                opt = obj.get_dpm().dp_opt(opt);
            end

            if (isequal(opt.id_filter, []))
                opt.id_filter = {};
            end

            if (~iscell(opt.id_filter))
                opt.id_filter = {opt.id_filter};
            end

        end

    end

    methods (Static, Hidden)

        function s = ensure_field(s, f, v)
            if (~isfield(s, f))
                s.(f) = v;
            end
        end

        function s = gently_copy_field(s, f, s2)
            if (~isfield(s, f)) && (isfield(s2, f))
                s.(f) = s2.(f);
            end
        end

        function a = merge_opt(a, b)

            f = fieldnames(b);
            for c = 1:numel(f)
                a.(f{c}) = b.(f{c});
            end


        end

    end

end