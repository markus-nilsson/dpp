classdef dp_node_fsl_eddy_run < dp_node

    methods

        function output = i2o(obj, input)

            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_eddy');

        end

        function output = execute(obj, input, output)
        
            % make a temporary out fn without .nii.gz
            [a,b] = msf_fileparts(output.dmri_fn);
            out_fn = fullfile(a,b);

            cmd = ['eddy ' ...
                sprintf('--imain=%s ', input.dmri_fn) ...
                sprintf('--mask=%s ', input.mask_fn) ...
                sprintf('--acqp=%s ', input.acqp_fn) ...
                sprintf('--index=%s ', input.index_fn) ...
                sprintf('--bvecs=%s ', input.bvec_fn) ...
                sprintf('--bvals=%s ', input.bval_fn) ...
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
                
        end

    end

end


