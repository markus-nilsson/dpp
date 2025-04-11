classdef dui_show_node < handle

    properties
        h_props;
        h; % parent
        g;
    end

    methods

        function obj = dui_show_node(h)

            obj.h = h; % parent

            h.Units = 'Pixels';
            h.Position;

            h_height = h.Position(4);
            h_width = h.Position(3);

            % properties
            p_margin = 10;
            p_left = p_margin;
            p_bottom = p_margin;
            p_height = h_height - 2 * p_margin - 20;
            p_width = h_width - 2 * p_margin;

            obj.h_props = uitable(h, ...
                'Position', [p_left p_bottom p_width p_height]);            


        end

        function set_node(obj, node)

            f = fieldnames(node);

            hidden_props = {'mode', 'opt', 'log_fn', 'dpm_list', 'previous_node', 'name'};

            % Hide additional fields unless ROIs have been modified and
            % named
            if (numel(node.roi_names) > 0) && ...
                (strcmp(node.roi_names{1}, 'Temporary'))

                hidden_props = cat(2, hidden_props, ...
                    'roi_use_single', ...
                    'roi_bp', ...
                    'roi_names', ...
                    'roi_ids', ...
                    'roi_can_be_modified');

            end

            data = {};
            for c = 1:numel(f)

                if (any(strcmp(f{c}, hidden_props))), continue; end

                if (strcmp(f{c}, 'roi_ids'))
                    1;
                end
    
                data{end+1,1} = f{c};

                value = node.(f{c});
                switch (class(value))
                    case 'char'
                        1; % pass it along
                    case 'cell'
                        if (isempty(value))
                            value = '{}';
                        else
                            value = char(strtrim(formattedDisplayText(value)));
                        end
                    case {'logical', 'double'}
                        value = num2str(value);
                    otherwise

                        if (isa(value, 'dp_node'))
                            value = class(value);
                        elseif (isnumeric(value))
                            1;
                        else
                            value = '-';
                        end

                end
                data{end,2} = value;
                
            end

            obj.h_props.Data = data;

        end

    end
end

