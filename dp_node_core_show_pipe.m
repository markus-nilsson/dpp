classdef dp_node_core_show_pipe < handle

    properties (Hidden)
        idx;
        current_idx;

        h_items;
        h_input;
        h_output;

        primary_outputs;
    end

    properties (Abstract)
        name;
        previous_node;
    end

    methods

        function show_pipe(obj)

            % Make sure every node has a unique ID
            obj.clean_id();

            f = @(x) obj.get_new_id(); 
            obj.set_id(f);

            edges = obj.buildGraph([]);
            edges = unique(edges, 'rows');
            names = obj.get_names();

            G = digraph(edges(:,1), edges(:,2), [], names);


            % Get first primary node
            primary_node = obj.get_primary_node();
            obj.primary_outputs = primary_node.get_iterable();
            ids = cellfun(@(x)x.id, obj.primary_outputs, 'UniformOutput',false);

            % % Plot the graph using a layered layout.
            hf = uifigure(...
                'Name', 'Nodegraph', ...
                'Position',[100 100 1200 820]);

            ha = axes(hf, ...
                'units', 'pixels', ...
                'position', [280 10 400 770]);

            h = plot(ha, G, 'Layout', 'layered', 'LineWidth', 2);
            set(h, ...
                'NodeFontSize', 12, ...
                'MarkerSize', 12, ...
                'NodeColor', 'black');
            title(ha, 'dp\_node Pipeline Connections');
            axis(ha, 'off');


            obj.h_items = uilistbox(hf, ...
                'Position', [10 10 250 800], ...
                'Items', ids, ...
                'ValueChangedFcn', @(s,e) obj.ui_items(s,e));           
            obj.h_input = uilistbox(hf, ...
                'Position', [780 410 410 400]);

            obj.h_output = uilistbox(hf, ...
                'Position', [780 10 410 390]);
            

        end
    end

    methods (Hidden)

        function ui_items(obj, s,e)

            input = obj.primary_outputs{obj.h_items.ValueIndex};

            output = obj.run('iter', struct('id_filter', obj.h_items.Value));
            
            1;

        end


        function nodes = get_previous_nodes(obj)

            if (isa(obj, 'dp_node_io_merge')) % dont do this here
                nodes = obj.previous_nodes;
            elseif (~isempty(obj.previous_node))
                nodes = {obj.previous_node};
            else
                nodes = {};
            end
        end

        function node = get_primary_node(obj)

            nodes = obj.get_previous_nodes();

            if (isempty(nodes))
                node = obj;
            else
                node = nodes{1}.get_primary_node();
            end               

        end

        function idx = get_new_id(obj)
            idx = obj.current_idx;
            obj.current_idx = obj.current_idx + 1;
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

        function edges = buildGraph(obj, edges)

            % If the node is a merge node (dp_node_io_merge),
            % process its previous_nodes cell array.
            nodes = obj.get_previous_nodes();

            for c = 1:length(nodes)

                % Record the edge from the previous node to the current node
                edges = [edges; nodes{c}.idx, obj.idx];

                % Recurse on the previous node
                edges = nodes{c}.buildGraph(edges);

            end

        end
    end


    % 
    % methods
    %     function plotPipeline(currentNode)
    %         % Recursively build the node names and edge list from the current node
    %         [nodeNames, edges] = buildGraph(currentNode, {}, []);
    % 
    %         % Create a directed graph using node indices
    %         if isempty(edges)
    %             error('No connections found.');
    %         end
    %         G = digraph(edges(:,1), edges(:,2), [], nodeNames);
    % 
    %         % Plot the graph with a layered layout
    %         figure;
    %         plot(G, 'Layout', 'layered');
    %         title('dp\_node Pipeline');
    %     end
    % 
    %     
    % 
    % end

end


