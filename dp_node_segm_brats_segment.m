classdef dp_node_segm_brats_segment < dp_node

    % xxx: prototype

    methods

        % construct names of output files
        function output = i2o(obj, input)

            nii_path = fullfile(input.op, 'segmentation');

            output.op = nii_path;
            output.hnfnet_fn   = fullfile(nii_path, 'hnfnetv1-20.nii.gz');
            output.isen_fn     = fullfile(nii_path, 'isen-20.nii.gz');
            output.sanet_fn    = fullfile(nii_path, 'sanet0-20.nii.gz');
            output.yixinmpl_fn = fullfile(nii_path, 'yixinmpl-20.nii.gz');

            % cannot get scan working for now, try again later
            %output.scan_fn = fullfile(nii_path, 'scan-20.nii.gz');

        end

        function output = execute(obj, input, output)
           
            % run python script

            cmd = sprintf(['python3 %s/tumseg_fn_segment.py ' ...
                '%s ' ...
                '%s ' ...
                '%s ' ...
                '%s ' ...
                '%s '], ...
                fileparts(mfilename('fullpath')), ...
                output.op, ...
                input.t1_fn, ...
                input.t1c_fn, ...
                input.t2_fn, ...
                input.flair_fn);

            [s, r] = msf_system(cmd);

            if (s ~= 0), error(r); end
        end
    end
end









