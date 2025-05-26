classdef dui_show_graph < handle

    % Could be hidden?
    properties (Hidden)
        h; % figure
        node;
        fn_output_node_change = @(node) 1;
        fn_input_node_change = @(node) 1;
        h_input_marker = [];
        h_output_marker = [];
        h_input; % button
        h_output; % button
        h_graph;
        h_axes;
        input_color = [.25, 0.45, 0.75];
        output_color = [0.8, 0.5, 0.25];
    end

    % Will be used by the outside
    properties
        input_node = [];
        output_node = [];
    end
    

    methods

        function obj = dui_show_graph(h, node, ...
                fn_input_node_change, fn_output_node_change)
            
            % Input management
            obj.h = h;
            obj.node = node;

            if (nargin > 2), obj.fn_input_node_change =  fn_input_node_change; end
            if (nargin > 3), obj.fn_output_node_change =  fn_output_node_change; end
             
            % Set up figure
            h.Units = 'Pixels';
            h.Position;

            h_height = h.Position(4);
            h_width = h.Position(3);

            % Construct the graph plot
            p_margin = 10;
            p_button = 30;

            p_left = p_margin;
            p_bottom = p_margin;
            
            p_width = h_width - 2 * p_margin;
            p_height = h_height - 2 * p_margin - (p_button + p_margin);
                      
            obj.h_axes = axes(obj.h, ...
                'units', 'pixels', ...
                'position', [p_left p_bottom p_width p_height]);

            obj.h_graph = plot(obj.h_axes, node.get_graph(), 'Layout', 'layered', 'LineWidth', 2);

            set(obj.h_graph, ...
                'NodeFontSize', 12, ...
                'MarkerSize', 12, ...
                'NodeColor', 'black', ...
                'ButtonDownFcn', @(s,e) obj.graph_click(s,e));

            axis(obj.h_axes, 'off');

            % Add buttons
            p_left = p_margin;
            p_bottom = p_height + p_bottom - p_margin;
            p_width = 100;
            p_height = p_button;

            obj.h_input = uibutton(obj.h, ....
                'position', [p_left p_bottom p_width p_height], ...
                'text', 'Input', ...
                'fontcolor', obj.input_color, ...                
                'ButtonPushedFcn', @(s,e) obj.input_clicked());


            p_left = p_left + p_width + p_margin;

            obj.h_output = uibutton(obj.h, ....
                'position', [p_left p_bottom p_width p_height], ...
                'text', 'Output', ...
                'fontweight', 'bold', ...
                'fontcolor', obj.output_color, ...
                'ButtonPushedFcn', @(s,e) obj.output_clicked());
            
        end

        function input_clicked(obj)
            obj.h_input.FontWeight = 'bold';
            obj.h_output.FontWeight = 'normal';
        end

        function output_clicked(obj)
            obj.h_output.FontWeight = 'bold';
            obj.h_input.FontWeight = 'normal';
        end
        

        function graph_click(obj, src, ~)

            % Get the axes where the click happened
            ax = ancestor(src, 'axes');

            % Get click location in data coordinates
            clickPoint = ax.CurrentPoint(1, 1:2);

            % Get node positions
            nodeX = src.XData;
            nodeY = src.YData;

            % Compute distances from click to all nodes
            distances = hypot(nodeX - clickPoint(1), nodeY - clickPoint(2));

            % Define a click threshold (adjust as needed)
            threshold = 0.5;  % depends on axis scale

            % Find closest node within threshold
            [minDist, idx] = min(distances);

            if (minDist > threshold)
                return;
            end

            % Identify node by its name
            tmp = src.NodeLabel{idx};
            idx = str2double(tmp(1: (-1 + (find(tmp == ':', 1, 'first')))));

            selected_node = obj.node.get_node_by_idx(idx);
            

            % Determine whether we are doing input or output
            bi = strcmp(obj.h_input.FontWeight, 'bold');
            bo = strcmp(obj.h_output.FontWeight, 'bold');
            
            if (bi) && (~bo) % input active

                % Update UI
                obj.input_node = selected_node;
                obj.fn_input_node_change(selected_node);                

            elseif (~bi) && (bo)

                % Update UI
                obj.output_node = selected_node;
                obj.fn_output_node_change(selected_node);

            else
                error('something is off');
            end

            obj.plot_input_and_output();

        end

        function plot_input_and_output(obj)

            nodeX = obj.h_graph.XData;
            nodeY = obj.h_graph.YData;

            % Display the input node
            idx = obj.input_node.idx;
            delete(obj.h_input_marker);
            hold(obj.h_axes, 'on');
            obj.h_input_marker = plot(obj.h_axes, nodeX(idx), nodeY(idx), ...
                'o', ...
                'color', obj.input_color, ...
                'markersize', 14, 'linewidth', 2);

            % Display the output node
            idx = obj.output_node.idx;            
            delete(obj.h_output_marker);
            hold(obj.h_axes, 'on');
            obj.h_output_marker = plot(obj.h_axes, nodeX(idx), nodeY(idx), ...
                'o', ...
                'color', obj.output_color, ...
                'markersize', 14, 'linewidth', 2);
                
            
        end


    end

end
