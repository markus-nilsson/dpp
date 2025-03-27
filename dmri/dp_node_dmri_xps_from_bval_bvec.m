classdef dp_node_dmri_xps_from_bval_bvec < dp_node_dmri_xps

    properties
        b_delta = 1;
    end

    methods

        function obj = dp_node_dmri_xps_from_bval_bvec(b_delta)
            obj.b_delta = b_delta;
        end

        function output = execute(obj, input, output)

            xps = mdm_xps_from_bval_bvec(...
                input.bval_fn, input.bvec_fn, obj.b_delta);

            mdm_xps_save(xps, output.xps_fn);

        end
    end
end