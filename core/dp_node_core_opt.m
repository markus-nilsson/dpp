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
        opt; % this is what the node will report
    end
    
    properties (Hidden)
        opt_runtime = [];
        opt_node = [];
    end

    methods

        function obj = dp_node_core_opt() 
            obj.opt_node.present = 1;
        end

        % Store the runtime opts in the primary node
        function set.opt_runtime(obj, opt)
            obj.get_primary_node().opt_runtime = opt;
        end

        % Keep track of how deeply we have recursed
        function set_c_level(obj)
            
            % Update 
            tmp = obj.get_primary_node().opt_runtime;
            tmp = obj.ensure_field(tmp, 'c_level', 0);
            tmp.c_level = tmp.c_level + 1;
            obj.get_primary_node().opt_runtime = tmp;

            obj.opt_node.c_level = tmp.c_level;
        end

        function opt = get.opt(obj)

            f = @(x, field, val) obj.ensure_field(x, field, val);

            % First grab the runtime options
            opt = obj.get_primary_node().opt_runtime;

            % Gently add node's options
            g = @(x, field) obj.gently_copy_field(x, field, obj.opt_node);            
            opt = g(opt, 'do_overwrite');
            
            % Forcefully add the node's c_level
            if (isfield(obj.opt_node, 'c_level'))
                opt.c_level = obj.opt_node.c_level;
            end


            % Gently add default options
            opt = f(opt, 'verbose', 0);
            opt = f(opt, 'do_try_catch', 1);
            opt = f(opt, 'iter_mode', 'iter');
            opt = f(opt, 'deep_mode', 0);
            opt = f(opt, 'do_overwrite', 0);
            opt = f(opt, 'c_level', 0);
            opt = f(opt, 'id_filter', {});

            if (~isempty(obj.mode))
                opt = obj.get_dpm().dp_opt(opt);
            end

            if (~iscell(opt.id_filter))
                opt.id_filter = {opt.id_filter};
            end

        end


        function obj = update(~, ~, ~) % set necessary properties
            error('not used any more');

            % --> this is no longer implemented
            %
            % % not sure if this is always a good idea, but let us try it
            % if (~isempty(obj.previous_node)) && (obj.opt.deep_mode)
            %     obj.previous_node.do_dpm_passthrough = 1;
            %     obj.previous_node.update(obj.opt, mode);
            % end

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


    end

end