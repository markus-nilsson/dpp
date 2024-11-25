classdef p10_md < dp_node_md

    methods

        function obj = p10_md()
            obj.previous_node = {p6_mask, p7_powder_averaging};
            obj.opt = struct('filter_sigma', 1.0);

            % defaults for mdt mapping
            obj.b_min = 0.0e9;
            obj.b_max = 1.0e9;
            obj.b_delta = 1;
            obj.name = 'MD';

        end

        function input = po2i(obj, prev_output)
            input.bp = prev_output.powder_averaging_bp;
            input.nii_fn = prev_output.powder_averaging_nii_fn;
            input.mask_fn = prev_output.mask_nii_fn;
        end

    end
end



