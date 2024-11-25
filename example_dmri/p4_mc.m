classdef p4_mc < dp_node_mec_ep

    methods

        function obj = p4_mc()
            obj.previous_node = p3_topup;
        end

        function input = po2i(obj, previous_output)
            input.bp = previous_output.bp;
            input.nii_fn = previous_output.nii_fn;

            input.opt = mdm_opt(previous_output.opt);
            input.opt.do_overwrite = 1;

            % necessary for the limited LTE data here
            input.opt.mio.ref_extrapolate.do_subspace_fit = 1;
            input.elastix_p = elastix_p_affine(200);

        end

    end
end
