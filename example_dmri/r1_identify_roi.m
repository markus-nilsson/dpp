classdef r1_identify_roi < dp_node

    methods 

        function obj = r1_identify_roi()
            bp = '/media/fuji/MyBook1/BOF130_APTw/data/seg';
            obj.previous_node = p0_list_subjects(bp);
        end

        function output = i2o(obj, input)

            output.bp = input.bp;

            roi_path = fullfile(input.bp, input.id);

            output.roi_fn = msf_find_fn(roi_path, 'segfusionmav.nii.gz');


        end

    end

end


