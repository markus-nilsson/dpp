classdef dui_show_log < handle

    % Show logs: I do not like this code, it was written by ChatGPT.
    % Not pretty, but quick. 

    properties
        parent_handle       % Handle provided to the class (a figure or uipanel)
        control_panel       % Panel for controls inside the parent
        listbox_logs        % Listbox to display log messages in the parent
        edit_filter         % Edit field for keyword filtering
        popup_level         % Dropdown for log level selection
        log_messages        % Cell array storing log message structs
        fullscreen_fig      % Handle for full screen figure (if open)
        fullscreen_listbox  % Listbox in full screen viewer
    end
    
    methods
        function obj = dui_show_log(parent_handle)
            % dui_show_log - Constructor: builds the log viewer UI inside a given parent handle.
            %
            % Usage:
            %   viewer = dui_show_log(parent_handle);
            %
            % The parent_handle should be a valid figure or uipanel.
            
            if nargin < 1 || ~ishandle(parent_handle)
                error('A valid parent handle must be provided.');
            end
            obj.parent_handle = parent_handle;
            obj.log_messages = {};
            
            % Get parent's size in pixels
            parent_pos = get(parent_handle, 'Position');  % [x, y, width, height]
            parent_width = parent_pos(3);
            parent_height = parent_pos(4);
            
            % Define layout constants (in pixels)
            control_panel_height = 40;
            margin = 10;
            btn_height = 30;
            % Button widths
            btn_width_clear   = 80;
            btn_width_level   = 80;
            label_width_filter = 40;
            edit_width_filter  = 100;
            btn_width_save    = 80;
            btn_width_full    = 150;
            
            % Create control panel at the top of the parent
            obj.control_panel = uipanel('Parent', parent_handle, ...
                'Units', 'pixels', ...
                'Position', [2, -22 + parent_height - control_panel_height, parent_width - 4, control_panel_height - 4]);

            obj.control_panel.BorderWidth = 0;
            
            % Compute vertical offset (to center controls in the control panel)
            y_offset = (control_panel_height - btn_height) / 2;
            x_offset = margin;
            
            % Clear Log button
            uicontrol('Parent', obj.control_panel, ...
                'Style', 'pushbutton', ...
                'String', 'Clear Log', ...
                'Units', 'pixels', ...
                'Position', [x_offset, y_offset, btn_width_clear, btn_height], ...
                'Callback', @(src,event)obj.clear_log_callback(src,event));
            
            x_offset = x_offset + btn_width_clear + margin;
            % Log Level dropdown
            levels = {'Level 0','Level 1','Level 2','Level 3','Errors Only'};
            obj.popup_level = uicontrol('Parent', obj.control_panel, ...
                'Style', 'popupmenu', ...
                'String', levels, ...
                'Units', 'pixels', ...
                'Position', [x_offset, y_offset, btn_width_level, btn_height], ...
                'Callback', @(src,event)obj.log_level_callback(src,event));
            
            x_offset = x_offset + btn_width_level + margin;
            
            % Filter label
            uicontrol('Parent', obj.control_panel, ...
                'Style', 'text', ...
                'String', 'Filter:', ...
                'Units', 'pixels', ...
                'HorizontalAlignment', 'left', ...
                'Position', [x_offset, y_offset - 10, label_width_filter, btn_height]);
            
            x_offset = x_offset + label_width_filter + margin;
            
            % Filter edit field
            obj.edit_filter = uicontrol('Parent', obj.control_panel, ...
                'Style', 'edit', ...
                'Units', 'pixels', ...
                'Position', [x_offset, y_offset, edit_width_filter, btn_height], ...
                'Callback', @(src,event)obj.filter_callback(src,event));
            
            x_offset = x_offset + edit_width_filter + margin;
            
            % Save to File button
            uicontrol('Parent', obj.control_panel, ...
                'Style', 'pushbutton', ...
                'String', 'Save to File', ...
                'Units', 'pixels', ...
                'Position', [x_offset, y_offset, btn_width_save, btn_height], ...
                'Callback', @(src,event)obj.save_log_callback(src,event));
            
            x_offset = x_offset + btn_width_save + margin;
            
            % Open Fullscreen button
            uicontrol('Parent', obj.control_panel, ...
                'Style', 'pushbutton', ...
                'String', 'Open Fullscreen', ...
                'Units', 'pixels', ...
                'Position', [x_offset, y_offset, btn_width_full, btn_height], ...
                'Callback', @(src,event)obj.open_fullscreen(src,event));
            
            % Create log display area (listbox) in the remaining space of the parent
            obj.listbox_logs = uilistbox('Parent', parent_handle, ...
                'Position', [margin, margin, parent_width - 2*margin, parent_height - control_panel_height - 2*margin - 15]);
        end
        
        function add_log_message(obj, level, text)
            % add_log_message - Append a new log message.
            %
            % Usage:
            %   obj.add_log_message(level, text)
            %
            % level: numeric value (1-4 for normal messages; use 0 for errors)
            % text: log message string
            
            new_msg.level = level;
            new_msg.text  = text;
            obj.log_messages{end+1} = new_msg;
            obj.update_log_display();
        end
        
        function update_log_display(obj)
            % update_log_display - Refresh the log display (embedded and fullscreen).
            %
            % Applies log level and keyword filters.
            
            levels = get(obj.popup_level, 'String');
            sel = get(obj.popup_level, 'Value');
            level_filter = levels{sel};
            keyword = get(obj.edit_filter, 'String');
            disp_messages = {};
            
            for i = 1:length(obj.log_messages)

                msg = obj.log_messages{i};                
                
                % Filter by log level
                % if strcmp(level_filter, 'Errors Only')
                %     if msg.level == 0
                %         show_msg = true;
                %     end
                % else
                %     tokens = regexp(level_filter, 'Level (\d)', 'tokens');
                %     if ~isempty(tokens)
                %         lvl = str2double(tokens{1}{1});
                %         if msg.level == lvl
                %             show_msg = true;
                %         end
                %     end
                % end

                switch (level_filter)
                    case 'Level 0'
                        th = 0;
                    case 'Level 1'
                        th = 1;
                    case 'Level 2'
                        th = 2;
                    case 'Level 3'
                        th = 3;
                    case 'Level 4'
                        th = inf;
                    otherwise
                        th = 1;
                end

                if (msg.level > th)
                    continue;
                end

                show_msg = true;
                        
                % Apply keyword filter if provided
                if show_msg && ~isempty(keyword)
                    if (isempty(strfind(lower(msg.text), lower(keyword))))
                        return;
                    end
                end
                
                disp_messages{end+1} = msg.text;
            end
            
            % Update the embedded listbox
            obj.listbox_logs.Items = disp_messages;
            
            % Update the fullscreen listbox if open
            if ~isempty(obj.fullscreen_listbox) && ishandle(obj.fullscreen_listbox)
                %set(obj.fullscreen_listbox, 'String', disp_messages);
            end

            obj.listbox_logs.FontName = 'Courier';
            obj.listbox_logs.FontWeight = 'Bold';

            % if (numel(disp_messages) > 0)
            %     obj.listbox_logs.ValueIndex = 1;
            %     drawnow;
            %     obj.listbox_logs.ValueIndex = numel(disp_messages);
            % end

        end
        
        function clear_log_callback(obj, ~, ~)
            % clear_log_callback - Clear all stored log messages.
            obj.log_messages = {};
            obj.update_log_display();
        end
        
        function log_level_callback(obj, ~, ~)
            % log_level_callback - Refresh display when log level selection changes.
            obj.update_log_display();
        end
        
        function filter_callback(obj, ~, ~)
            % filter_callback - Refresh display when filter text changes.
            obj.update_log_display();
        end
        
        function save_log_callback(obj, ~, ~)
            % save_log_callback - Save the currently displayed log messages to a file.
            [file, path] = uiputfile('log.txt', 'Save Log');
            if ischar(file)
                full_path = fullfile(path, file);
                fid = fopen(full_path, 'w');
                if fid == -1
                    errordlg('Cannot open file for writing', 'File Error');
                    return;
                end
                disp_messages = get(obj.listbox_logs, 'String');
                for j = 1:length(disp_messages)
                    fprintf(fid, '%s\n', disp_messages{j});
                end
                fclose(fid);
            end
        end
        
        function open_fullscreen(obj, ~, ~)
            % open_fullscreen - Open a new full screen window displaying the log messages.
            %
            % If a fullscreen viewer is already open, bring it to the front.
            
            if ~isempty(obj.fullscreen_fig) && ishandle(obj.fullscreen_fig)
                figure(obj.fullscreen_fig);  % bring to front
                return;
            end
            
            % Get screen size in pixels
            screen_size = get(0, 'ScreenSize');  % [left, bottom, width, height]
            obj.fullscreen_fig = figure('Name', 'Log Viewer (Fullscreen)', ...
                'NumberTitle', 'off', ...
                'Units', 'pixels', ...
                'Position', screen_size, ...
                'CloseRequestFcn', @(src,event)obj.close_fullscreen(src,event));
            
            % Create a listbox that fills the fullscreen figure
            obj.fullscreen_listbox = uicontrol('Parent', obj.fullscreen_fig, ...
                'Style', 'listbox', ...
                'Units', 'pixels', ...
                'Position', [0, 0, screen_size(3), screen_size(4)], ...
                'Max', 2, ...
                'String', get(obj.listbox_logs, 'String'));
        end
        
        function close_fullscreen(obj, src, ~)
            % close_fullscreen - Callback to handle closing the fullscreen window.
            delete(src);
            obj.fullscreen_fig = [];
            obj.fullscreen_listbox = [];
        end
    end
end