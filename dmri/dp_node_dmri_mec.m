classdef dp_node_dmri_mec < dp_node

    % Performs motion and eddy current correction for diffusion MRI data using ELASTIX.
    % Corrects for subject motion and scanner-related distortions during diffusion acquisition.

    methods

        function input = po2i(obj, po)
            input = po;
            if (~isfield(input, 'elastix_p'))
                input.elastix_p = elastix_p_affine(100);
            end
            input.opt = mdm_opt();
        end
        
        function output = i2o(obj, input)

            output.op = input.op; % motion correction needs this
            output.dmri_fn = msf_fn_new_path(input.op, msf_fn_append(input.dmri_fn, '_mc'));
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            output.elastix_p_fn = fullfile(input.op, 'p.txt');

        end

        function output = execute(obj, input, output)
        
            % diffusion data
            s = mdm_s_from_nii(input.dmri_fn);

            % motion correction of reference
            elastix_p_write(input.elastix_p, output.elastix_p_fn);

            % register low b-value data to reference
            mdm_mec_b0(s, output.elastix_p_fn, output.op, input.opt);

        end

    end

end


