classdef r2_seg2roi < dp_node

    methods 

        function obj = r2_seg2roi()
            obj.previous_node = r1_identify_roi;
        end

        function output = i2o(obj, input)

            output.bp = input.bp;

            roi_path = fullfile(input.bp, input.id, 'roi');

            output.ce_fn    = fullfile(roi_path, 'roi_ce.nii.gz');
            output.edema_fn = fullfile(roi_path, 'roi_edema.nii.gz');
            output.tum_fn   = fullfile(roi_path, 'roi_tum.nii.gz');

        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.roi_fn);

            mdm_nii_write(uint8(I == 1), output.tum_fn, h);
            mdm_nii_write(uint8(I == 2), output.edema_fn, h);
            mdm_nii_write(uint8(I == 4), output.ce_fn, h);
            

        end

    end

end


