classdef dp_node_segm_brats_segment < dp_node

    % xxx: prototype

    methods

        % construct names of output files
        function output = i2o(obj, input)

            nii_path = fullfile(input.op, 'segmentation');

            output.hnfnet_fn   = fullfile(nii_path, 'hnfnetv1-20.nii.gz');
            output.isen_fn     = fullfile(nii_path, 'isen-20.nii.gz');
            output.sanet_fn    = fullfile(nii_path, 'sanet0-20.nii.gz');
            output.yixinmpl_fn = fullfile(nii_path, 'yixinmpl-20.nii.gz');

            % cannot get scan working for now, try again later
            %output.scan_fn = fullfile(nii_path, 'scan-20.nii.gz');

        end

        function output = execute(obj, input, output)
            % run a python script here
            % either pull from previous project or see if it can 
            % be called directly
        end
    end
end









