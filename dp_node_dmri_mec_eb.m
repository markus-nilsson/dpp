classdef dp_node_dmri_mec_eb < dp_node_dmri

    methods

        function input = po2i(obj, po)
            input = po2i@dp_node_dmri(obj, po);
            
            if (~isfield(input, 'elastix_p'))
                input.elastix_p = elastix_p_affine(100);
            end

            if (~isfield(input, 'mdm_opt'))
                input.mdm_opt = mdm_opt();
            end
        end
        
        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_mc');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            output.elastix_p_fn = fullfile(input.op, 'p.txt');

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
        end

        function output = execute(obj, input, output)

            % working directory
            wp = output.tmp.bp;

            % diffusion data
            s = mdm_s_from_nii(input.dmri_fn);

            % motion correction of reference
            elastix_p_write(input.elastix_p, output.elastix_p_fn);

            % register low b-value data to reference
            s_tmp = mdm_s_subsample(s, s.xps.b < 1.1e9, wp, input.mdm_opt);
            s_mec  = mdm_mec_b0(s_tmp, output.elastix_p_fn, wp, input.mdm_opt);

            % extrapolation-based motion correction
            mdm_mec_eb(s, s_mec, output.elastix_p_fn, output.op, input.mdm_opt);

        end

    end

end


