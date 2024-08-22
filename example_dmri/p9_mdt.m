classdef p9_mdt < dp_node % this class predates the implementatino of dp_node_mdt

    methods

        function obj = p9_mdt()
            obj.previous_node = {p6_mask, p7_powder_averaging};
        end


        function input = po2i(obj, prev_output) % build input to this step from previous output

            input.bp = prev_output.powder_averaging_bp;
            input.nii_fn = prev_output.powder_averaging_nii_fn;
            input.mask_fn = prev_output.mask_nii_fn;

        end

        function output = i2o(obj, input)

            op = msf_fileparts(input.nii_fn);
            output.bp = input.bp;
            output.nii_fn = fullfile(op, 'mdt_ste.nii.gz');

        end

        function output = execute(obj, input, output)

            % diffusion data
            s_pa = mdm_s_from_nii(input.nii_fn);
            s_pa.mask_fn = input.mask_fn;


            M = mdm_nii_read(input.mask_fn);

            [I,h] = mdm_nii_read(input.nii_fn);

            ind1 = abs(s_pa.xps.b - 1.4e9) < 0.1e9 & (s_pa.xps.b_delta < 0.1);
            ind2 = abs(s_pa.xps.b - 2.0e9) < 0.1e9 & (s_pa.xps.b_delta < 0.1);

            MDT = (log(I(:,:,:,ind1)) - log(I(:,:,:,ind2))) / (2.0 - 1.4);

            MDT(MDT > 3.0e9) = 3.0e9;
            MDT(MDT < 0) = 0;

            MDT = MDT .* M;

            mdm_nii_write(MDT, output.nii_fn, h);


        end

    end

end




