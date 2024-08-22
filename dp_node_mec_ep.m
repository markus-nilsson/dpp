classdef dp_node_mec_ep < dp_node

    methods
        
        function output = i2o(obj, input)

            op = fullfile(input.bp, input.id);

            [~, name, ext] = msf_fileparts(input.nii_fn);

            output.op = op; % motion correction needs this
            output.nii_fn = fullfile(op, [name '_mc' ext]);
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);

            output.elastix_p_fn = fullfile(op, 'p.txt');

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
        end

        function output = execute(obj, input, output)

            % working directory
            wp = output.tmp.bp;

            % diffusion data
            s = mdm_s_from_nii(input.nii_fn);

            % motion correction of reference
            elastix_p_write(input.elastix_p, output.elastix_p_fn);

            % register low b-value data to reference
            s_tmp = mdm_s_subsample(s, s.xps.b < 1.1e9, wp, input.opt);
            s_mec  = mdm_mec_b0(s_tmp, output.elastix_p_fn, wp, input.opt);

            % extrapolation-based motion correction
            mdm_mec_eb(s, s_mec, output.elastix_p_fn, output.op, input.opt);

        end

    end

end


