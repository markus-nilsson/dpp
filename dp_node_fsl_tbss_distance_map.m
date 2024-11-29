classdef dp_node_fsl_tbss_distance_map < dp_node

    % make the distance map - should just be done once,
    % so there's an additional layer of control here, a 
    % bit sketchy and may cause problems, beware

    properties
        fa_threshold;
        do_execute_this = 1;
    end

    methods

        function obj = dp_node_fsl_tbss_distance_map(fa_threshold)
            obj.fa_threshold = fa_threshold;
        end
        
        function output = i2o(obj, input)
            output = input; % pass input to next node
            output.dist_map_fn = fullfile(...
                fileparts(input.fa_skeleton_fn), 'dist_map.nii.gz');
            output.fa_threshold = obj.fa_threshold;
        end

        function output = execute(obj, input, output)

            if (~obj.do_execute_this), return; end

            [M,h] = mdm_nii_read(input.fa_mask_fn);
            [I,h] = mdm_nii_read(input.fa_skeleton_fn);
            I = I > obj.fa_threshold;
            
            D = 1-double(M) + double(I);
            mdm_nii_write(int16(D), output.dist_map_fn, h);

            cmd = sprintf('distancemap -i %s -o %s', output.dist_map_fn, ...
                output.dist_map_fn);
            msf_system(cmd);

            % Make sure this is only executed once
            obj.do_execute_this = 0; 
            

        end

    end

end