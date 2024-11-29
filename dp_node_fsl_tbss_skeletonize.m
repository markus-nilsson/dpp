classdef dp_node_fsl_tbss_skeletonize < dp_node

    % skeletonize data

    properties
        search_rule_mask_fn = '/usr/local/fsl/data/standard/LowerCingulum_1mm.nii.gz';
    end

    methods

        function output = i2o(obj, input)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_skeleton');

            output.tmp = obj.make_tmp();
        end


        function output = execute(obj, input, output)

            % create masked fa
            [I,h] = mdm_nii_read(input.nii_fn);
            M = mdm_nii_read(input.fa_mask_fn);

            tmp_fn = fullfile(output.tmp.bp, 'tmp.nii');
            mdm_nii_write(double(I) .* double(M), tmp_fn, h);
            

            function x = f(x)
                [a,b] = msf_fileparts(x);
                x = fullfile(a,b);
            end

            cmd = sprintf('tbss_skeleton -i %s -p %1.2f %s %s %s %s', ...
                f(input.mean_masked_fa_fn), ...
                input.fa_threshold, ...
                f(input.dist_map_fn), ...
                f(obj.search_rule_mask_fn), ...
                f(tmp_fn), ...
                f(output.nii_fn));

            msf_mkdir(msf_fileparts(output.nii_fn));
            msf_delete(output.nii_fn);

            [r,s] = msf_system(cmd);
            
        end
    end

end