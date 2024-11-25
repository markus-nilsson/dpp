classdef p2_denoise < dp_node_denoise

    methods

        function obj = p2_denoise()
            obj.previous_node = p1_merge;
        end

        function input = po2i(obj, prev_output) % build input to this step from previous output
            input.bp = prev_output.bp;
            input.nii_fn = prev_output.fwf_ap_fn;
        end

    end

end




