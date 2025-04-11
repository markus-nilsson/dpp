classdef dui_show_subjects < handle

    properties
        h; % panel showing this
        g; % run button
        d; % dropbown
        h_items; % list box with items
        inputs; 
        input_node = [];
        output_node = [];
        fn_item_change; % outside function to call when item changes
    end

    properties
        selected_input = [];
    end

    methods

        function obj = dui_show_subjects(h, fn_item_change)

            obj.h = h;

            if (nargin < 2), fn_item_change = @(s,e) 1; end
            obj.fn_item_change = fn_item_change; 

            h.Units = 'Pixels';
            h.Position;

            h_top = h.Position(4);
            h_width = h.Position(3);

            p_top_margin = 20;
            p_margin = 10;
            p_left = p_margin;
            p_height = 30;
            p_bottom = h_top - p_height - p_margin - p_top_margin;
            p_width = floor((h_width - 3 * p_margin) / 2);

            obj.g = uibutton(obj.h, ...
                'position', [p_left p_bottom p_width p_height], ...
                'text', 'Run', ...
                'ButtonPushedFcn', @(s,e) obj.run(s,e));


            p_left = p_left + p_width + p_margin;

            obj.d = uidropdown(obj.h, ...
                'position', [p_left p_bottom p_width p_height]);

            % --

            p_left = p_margin;
            p_height = p_bottom - p_margin * 2; 
            p_bottom = p_margin;
            p_width = h_width - 2 * p_margin;

            obj.h_items = uilistbox(obj.h, ...
                'position', [p_left p_bottom p_width p_height], ...
                'Items', {'None'}, ...
                'ValueChangedFcn', @(s,e) obj.item_change(s,e));

        end

        function obj = set_input_node(obj, node)

            obj.input_node = node;

            obj.inputs = obj.input_node.run('iter'); 

            ids = cellfun(@(x)x.id, obj.inputs, 'UniformOutput',false);

            set(obj.h_items, 'Items', ids); 

        end

        function obj = set_output_node(obj, node)

            obj.output_node = node;
            set(obj.d, 'Items', node.get_supported_modes());
            
        end

        function obj = run(obj, s, e)

            if (isempty(obj.output_node))
                return;
            end

            dpm = obj.d.Items{obj.d.ValueIndex};
            obj.output_node.run(dpm);

        end

        function obj = item_change(obj, varargin)

            input = obj.inputs{obj.h_items.ValueIndex};

            obj.selected_input = input;

            obj.fn_item_change(input);


        end

    end


    methods (Static)

        function test_case(node)

            close all;
            h = uifigure('position', [100 100 500 500]);


            g = uipanel(h, ...
                'position', [10 10 200 480], ...
                'title', 'test', ...
                'fontsize', 12, ...
                'backgroundcolor', ...
                'white');

            a = dui_show_subjects(g);

            a.set_input_node(node)
            a.set_output_node(node);

        end

    end

end
