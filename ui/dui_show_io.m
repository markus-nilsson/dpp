classdef dui_show_io < handle

    properties
        h_input;
        h_output;
        h_mgui;
        h_copy;
        h; % parent
        g;
    end

    methods

        function obj = dui_show_io(h)

            obj.h = h; % parent

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

            obj.h_mgui = uibutton(obj.h, ...
                'position', [p_left p_bottom p_width p_height], ...
                'text', 'Open mgui', ...
                'ButtonPushedFcn', @(s,e) obj.open_mgui());

            p_left = p_left + p_margin + p_width;

            obj.h_copy = uibutton(obj.h, ...
                'position', [p_left p_bottom p_width p_height], ...
                'text', 'Copy field', ...
                'ButtonPushedFcn', @(s,e) obj.copy_field());
            
            % outputs
            p_left = p_margin;            
            p_width = h_width - 2 * p_margin;
            p_height = 190;
            p_bottom = p_margin;
            
            obj.h_output = uitable(h, ...
                'Position', [p_left p_bottom p_width p_height], ...
                'CellSelectionCallback', @(s,e) obj.ui_output_selected(), ...
                'Multiselect', 'off', ...
                'SelectionType','row');

            % inputs
            p_bottom = p_bottom + p_height + p_margin;
            p_height = 120;

            obj.h_input = uitable(h, ...
                'Position', [p_left p_bottom p_width p_height], ...
                'CellSelectionCallback', @(s,e) obj.ui_input_selected(), ...
                'Multiselect', 'off', ...
                'SelectionType','row');            


        end


        function [field, value] = get_selected_row(obj)
            i = obj.h_input.Selection;
            o = obj.h_output.Selection;

            if (isempty(i)) && (isempty(o))
                field = [];
                value = [];
            elseif (isempty(i)) && (~isempty(o))
                field = obj.h_output.Data{o, 1};
                value = obj.h_output.Data{o, 2};
            elseif (isempty(o)) && (~isempty(i))
                field = obj.h_input.Data{i, 1};
                value = obj.h_input.Data{i, 2};
            else
                disp('error');
                field = [];
                value = [];
                return;
            end
        end

        function copy_field(obj)
            [~,value] = obj.get_selected_row();
            clipboard('copy', value);
        end

        function open_mgui(obj)

            [field,value] = obj.get_selected_row();

            % if a filename and a nii.gz, open with
            if (strcmp(field(max(1, end-2):end), '_fn'))

                [~,~,ext] = msf_fileparts(value);

                if (strcmpi(ext, '.nii.gz')) || (strcmpi(ext, '.nii'))

                    EG.data.ref(1).fn = value;
                    EG.data.ref(1).name = field;
                    EG.data.roi_list = {};
                    EG.data.nii_fn_to_roi_fn = @(a,b) [];
                    mgui_close();
                    mgui(EG, 3);
                    return;

                end
            end

            uialert(obj.h.Parent, 'Not an image file (.nii)', 'Note');


        end

        function ui_input_selected(obj)
            obj.h_output.Selection = [];
        end

        function ui_output_selected(obj)
            obj.h_input.Selection = [];
        end
        
        function update(obj, node, input)
            obj.ui_update_inputs(input);
            obj.ui_update_outputs(node, input);
        end

        function ui_update_inputs(obj, input)
            
            if (isempty(input)), return; end

            % Update input items for this subject

            f = fieldnames(input);

            data = cell(numel(f), 2);
            for c = 1:numel(f)
                data{c,1} = f{c};
                data{c,2} = input.(f{c});
            end

            obj.h_input.Data = data;
            obj.h_input.RowName = [];
            obj.h_input.ColumnName = {'Input field', 'Value'};
            
        end   


        function ui_update_outputs(obj, node, input)

            if (isempty(node)), return; end

            % Update outputs for this subject (try to)
            try

                input_id = input.id;
                
                output = node.run('iter', struct(...
                    'id_filter', input_id, ...
                    'do_try_catch', 0));
                me = {};
            catch me
                output = {};
            end

            if (numel(output) == 1) %#ok<ISCL>
                
                output = output{1};

                f = fieldnames(output);

                data = cell(numel(f), 2);
                for c = 1:numel(f)
                    data{c,1} = f{c};
                    data{c,2} = output.(f{c});
                end
                
                % Update table
                obj.h_output.Data = data;
                obj.h_output.RowName = [];
                obj.h_output.ColumnName = {'Output field', 'Value'};
                
                % Make output test fields bold
                ind = find(cell2mat(cellfun(...
                    @(x) any(strcmp(x, node.output_test)), f, 'UniformOutput', false)));

                addStyle(obj.h_output, uistyle('FontWeight', 'bold'), ...
                    'row', ind);

                % Mark missing files with red
                ind = zeros(size(f));
                for c = 1:numel(f)

                    % Is it a filename field? Does file exist?
                    if (strcmp(f{c}(max(1, end-2):end), '_fn'))
                        ind(c) = exist(output.(f{c}), 'file') == 0;
                    end

                end
                ind = find(ind);

                addStyle(obj.h_output, uistyle('FontColor', 'red'), ...
                    'row', ind);


            else

                if (isempty(me))
                    me.message = 'No error reported';
                end


                obj.h_output.Data = {...
                    sprintf('#outputs = %i', numel(output)), ...
                    sprintf('Error: %s', me.message)};

            end

        end
        

    end

end

