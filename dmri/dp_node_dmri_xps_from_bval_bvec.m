classdef dp_node_dmri_xps_from_bval_bvec < dp_node_dmri_xps

    % Creates experimental parameter sets (XPS) from separate bval and bvec files. Combines
    % b-value and gradient direction information into unified acquisition parameter format.

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