classdef dp_node_fsl_eddy_run < dp_node

    properties
        % to avoid complaints in our data 
        % (Siemens used to compute the b-value, so it could end up as 
        %  b = 50 even for data intended to be b = 0 and we do not want
        %  those to be placed in their own shell, but, we also acquire
        %  data with b = 100, which we want to have in a shell of its own)
        b_range = 60; 
    end

    methods

        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_eddy');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

        end

        function output = execute(obj, input, output)
        
            % make a temporary out fn without .nii.gz
            [a,b] = msf_fileparts(output.dmri_fn);
            out_fn = fullfile(a,b);

            cmd = ['eddy_cuda10.2 ' ...
                'diffusion ' ...
                sprintf('--imain=%s ', input.dmri_fn) ...
                sprintf('--mask=%s ', input.mask_fn) ...
                sprintf('--acqp=%s ', input.acqp_fn) ...
                sprintf('--index=%s ', input.index_fn) ...
                sprintf('--bvecs=%s ', input.bvec_fn) ...
                sprintf('--bvals=%s ', input.bval_fn) ...
                sprintf('--data_is_shelled ') ...
                sprintf('--b_range=%i ', obj.b_range), ...
                sprintf('--out=%s ', out_fn)];

            % optional
                % 
                % sprintf('--topup=my_topup_results ') ...
                % sprintf('--repol ') ...
                % ];

            [a,b] = msf_system(cmd);
            
            if (a > 0)
                error(b);
            end

            % ideally, rotate b-vals and b-vecs here
            xps = mdm_xps_load(input.xps_fn);
            mdm_xps_save(xps, output.xps_fn);
                
        end

    end

end


