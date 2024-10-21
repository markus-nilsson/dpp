classdef dp_node_dmri_mec < dp_node

    methods

        function input = po2i(obj, po)
            input.elastix_p = elastix_p_affine(100);
        end
        
        function output = i2o(obj, input)

            op = fullfile(input.bp, input.id);

            output.op = op; % motion correction needs this
            output.nii_fn = msf_fn_append(input.nii_fn, '_mc');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);

            output.elastix_p_fn = fullfile(op, 'p.txt');

        end

        function output = execute(obj, input, output)
        
            % diffusion data
            s = mdm_s_from_nii(input.nii_fn);

            % motion correction of reference
            elastix_p_write(input.elastix_p, output.elastix_p_fn);

            % register low b-value data to reference
            s_mec  = mdm_mec_b0(s_tmp, output.elastix_p_fn, output.op, input.opt);

        end

    end

end


