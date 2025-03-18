classdef dpm_mgui < dpm_iter

    % this implementation is somewhat of a hack – but it works...

    methods

        function mode_name = get_mode_name(obj)
            mode_name = 'mgui';
        end

        function outputs = process_outputs(obj, outputs)
            dpm_mgui.open_mgui(outputs, obj.node, obj.node.opt);
        end

        function opt = dp_opt(obj, opt)
            1;
        end

        function output = run_on_one(obj, input, output)

            % transfer input to outputs, for later use with dp_node_roi
            % xxx: not really happy with this setup
            output.input = input; 
        end
        
    end
       
    methods (Static)

        function open_mgui(outputs, node, opt)

            % Build the EG.data.ref structure
            c_item = 0;
            
            for c = 1:numel(outputs)

                output = outputs{c};

                % For dp_node_roi, use inputs for drawing ROI's on
                % but for all other types of nodes, use their outputs
                if (isa(node, 'dp_node_roi'))
                    output = output.input;
                end

                f = fieldnames(output);

                for c2 = 1:numel(f)

                    try 
                        if (~contains(f{c2}, '_fn')), continue; end
                        if (~contains(output.(f{c2}), '.nii.gz')), continue; end
                    catch me
                        disp(me.message);
                    end

                    if (~exist(output.(f{c2}), 'file'))
                        continue;
                    end

                    % Take the ROI list from the node
                    EG.data.roi_list = node.roi_names;
                    
                    % Build a displayable id
                    id = output.id;
                    id = strrep(id, '/', ' ');
                    id = strrep(id, '\', ' ');

                    % This structure will be accessed by mgui, specifically
                    % ref.name will be displayed in the item list
                    ref.name = sprintf('%s: %s', id, f{c2});
                    ref.id = output.id;
                    ref.fn = output.(f{c2});
                    ref.f  = f{c2};
                    ref.output = output;

                    % allows information about display axes to be passed
                    if (isfield(output, 'caxis')) && isfield(output.caxis, f{c2})
                        ref.caxis = output.caxis.(f{c2});
                    else
                        ref.caxis = [];
                    end

                    % Store the reference
                    c_item = c_item + 1;
                    EG.data.ref(c_item) = ref;

                end

            end

            if (c_item == 0)
                error('No valid output ready for display');
            end
            
            % Provide mgui with a way to find the roi file
            function roi_fn = make_roi_fn(c_subject, c_roi)

                % Pass the request over to the node
                ref = EG.data.ref(c_subject);
                f = ref.f;
                output = ref.output;

                roi_fn = node.roi_get_fn(output, f, c_roi);

            end

            EG.data.nii_fn_to_roi_fn = @(a, b) make_roi_fn(a, b);
            
            
            % Is there already an mgui open? If so, close it. 
            h_fig = mgui_misc_get_mgui_fig();

            if (~isempty(h_fig)), close(h_fig); end

            % open the gui
            mgui(EG, 3);

            % make this work with legacy mdm frameworks
            h_fig = mgui_misc_get_mgui_fig();
            EG = get(h_fig,'userdata');
            EG.roi.present = 1;
            EG.roi.I_roi = [];
            EG.roi.is_updated = 0;
            EG.roi.roi_filename = [];
            set(h_fig,'userdata', EG);

            % xxx: possibly add a clean up by setting windows close fn
           


        end

    end

end