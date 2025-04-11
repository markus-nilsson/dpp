classdef dp_node_core_navigator < dp_node_core_pipeline_manager & handle

    methods

        function show_pipe(obj)
            dui_navigator(obj);
        end

    end

    methods

        function graph = get_graph(obj)

            % Make sure the IDs are set
            obj.update_node_ids();

            % Compute edges, eliminate doubles
            edges = unique(obj.get_edges(), 'rows');

            % Define graph
            graph = digraph(edges(:,1), edges(:,2), [], obj.get_names());

        end

        function edges = get_edges(obj, edges)

            if (nargin < 2), edges = []; end

            % If the node is a merge node (dp_node_io_merge),
            % process its previous_nodes cell array.
            nodes = obj.get_previous_nodes();

            for c = 1:length(nodes)

                % Record the edge from the previous node to the current node
                edges = [edges; nodes{c}.idx, obj.idx]; %#ok<AGROW>

                % Recurse on the previous node
                edges = nodes{c}.get_edges(edges);

            end

        end

    end
    
end