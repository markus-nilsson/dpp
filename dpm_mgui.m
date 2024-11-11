classdef dpm_mgui < dpm_iter

    methods

        function outputs = process_outputs(obj, outputs)

            dpm_mgui.open_mgui(outputs, obj.node, obj.node.opt);

        end

        function mode_name = get_mode_name(obj)
            mode_name = 'mgui';
        end

        function opt = dp_opt(obj, opt)
            1;
        end

        function output = run_on_one(obj, input, output)
            1;
        end
        
    end
       
    methods (Static)

        function open_mgui(outputs, node, opt)

            % Build the EG.data.ref structure
            c_item = 1;
            for c = 1:numel(outputs)

                output = outputs{c};

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

                    id = strrep(output.id, '/', ' ');

                    ref.name = sprintf('%s: %s', id, f{c2});
                    ref.id = output.id;
                    ref.fn = output.(f{c2});
                    ref.f  = f{c2};

                    ref.roi_bp = fullfile(output.bp, '..', 'roi_dp', output.id, class(node));
                    msf_mkdir(ref.roi_bp);

                    EG.data.ref(c_item) = ref;
                    c_item = c_item + 1;

                end

            end
            
            % add ROI lists later
            EG.data.roi_list = {'tmp'};

            EG.data.nii_fn_to_roi_fn = @(c_subject, c_roi) ...
                dpm_mgui.make_roi_fn(c_subject, c_roi, EG);
            
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


        end

        function roi_fn = make_roi_fn(c_subject, c_roi, EG)

            ref = EG.data.ref(c_subject); 

            roi_name = [EG.data.roi_list{c_roi} '_' ref.f];
            roi_name = lower(strrep(roi_name, ' ', '_'));

            ext = '.nii.gz';

            roi_fn = fullfile(ref.roi_bp, [roi_name ext]);

        end        

    end

end