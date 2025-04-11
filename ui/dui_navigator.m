classdef dui_navigator < handle


    % UI components
    properties (Hidden) 
        dui_inputs;
        dui_graph;
        dui_log;
        dui_io;
        dui_node;
    end


    methods

        function obj = dui_navigator(node)         
            
            % Starting in and output nodes
            input_node = node.get_primary_node();
            output_node = node;


            % Define the figure container
            hf = uifigure(...
                'Name', 'Pipeline Navigator', ...
                'Position',[100 100 1200 820], ...
                'Color', 'white');


            % Log panel: create and connect
            h_log = uipanel(hf, ...
                'position', [10 10 1180 250], ...
                'title', 'Log');

            obj.dui_log = dui_show_log(h_log);

            node.log_fn = @(l,s) obj.dui_log.add_log_message(l, s); 


            % Inputs panel
            h_inputs = uipanel(hf, ...
                'position', [10 10 + 260 260 800 - 260], ...
                'title', 'Inputs');

            obj.dui_inputs = dui_show_subjects(h_inputs, ...
                @(varargin) obj.ui_update_subject());

            obj.dui_inputs.set_input_node(input_node);
            obj.dui_inputs.set_output_node(output_node);


            % Graph panel
            h_graph = uipanel(hf, ...
                'position', [280 10 + 260 480 800 - 260], ...
                'title', 'Pipeline');

            obj.dui_graph = dui_show_graph(h_graph, node, ...
                @(varargin) obj.ui_update_input_node(), ...
                @(varargin) obj.ui_update_output_node());

            obj.dui_graph.input_node = input_node;
            obj.dui_graph.output_node = output_node;
            obj.dui_graph.plot_input_and_output(); 
            

            % Node properties
            h_props = uipanel(hf, ...
                'position', [780 10 + 260 + 400 + 10 410 130], ...
                'Title', 'Node properties');

            obj.dui_node = dui_show_node(h_props);
            obj.dui_node.set_node(node);

            % Inputs and outputs panel
            h_io_panel = uipanel(hf, ...
                'position', [780 10 + 260 410 400], ...
                'title', 'Input and output fields');
            
            obj.dui_io = dui_show_io(h_io_panel);
            

            % Finally: force update of in and out puts
            obj.dui_inputs.item_change(); 
            

        end
    end

    methods (Hidden)

        function ui_update_subject(obj)            
            obj.dui_io.update(obj.dui_graph.output_node, ...
                obj.dui_inputs.selected_input);
        end

        function ui_update_input_node(obj)
            obj.dui_inputs.set_input_node(obj.dui_graph.input_node);
        end
        
        function ui_update_output_node(obj)
            obj.dui_inputs.set_output_node(obj.dui_graph.output_node); 
            obj.dui_io.update(obj.dui_graph.output_node, obj.dui_inputs.selected_input);            
            obj.dui_node.set_node(obj.dui_graph.output_node); 
        end



    end

end


