classdef dp_node_core_pipeline_manager < handle

    % Code for managing nodes as a pipeline
    % The ID's of the nodes are created on request

    properties (Hidden)
        current_idx;
        idx;
    end

    methods

        % assigns 
        function idx = get_new_id(obj)
            idx = obj.current_idx;
            obj.current_idx = obj.current_idx + 1;
        end

        function node = get_node_by_idx(obj, idx)

            if (abs(obj.idx - idx) < 0.001)
                node = obj;
            else
                nodes = obj.get_previous_nodes();
                for c = 1:numel(nodes)
                    tmp = nodes{c}.get_node_by_idx(idx);
                    if (~isempty(tmp))
                        node = tmp;
                        return;
                    end
                end
                node = {};
            end

        end

        function clean_id(obj)
            obj.idx = [];
            obj.current_idx = 1;
            cellfun(@(x) x.clean_id, obj.get_previous_nodes());
        end

        function set_id(obj, f)

            if (~isempty(obj.idx))
                return;
            end

            nodes = obj.get_previous_nodes();
            for c = 1:numel(nodes)
                nodes{c}.set_id(f);
            end

            obj.idx = f();

        end

        function update_node_ids(obj)

            % First clean the idx of the pipeline
            obj.clean_id();

            % Set new id's to all (let this node's current_idx
            % count the number of nodes
            f = @(x) obj.get_new_id();
            obj.set_id(f);

        end
        

        function names = get_names(obj, names)

            if (nargin < 2), names = {}; end

            if (~isempty(obj.name))
                tmp = obj.name;
            else
                tmp = class(obj);
            end

            tmp = sprintf('%i: %s', obj.idx, tmp);
            tmp = strrep(tmp, '_', ' ');

            names{obj.idx} = tmp;

            nodes = obj.get_previous_nodes();

            for c = 1:numel(nodes)
                names = nodes{c}.get_names(names);
            end

        end

    end
end    

