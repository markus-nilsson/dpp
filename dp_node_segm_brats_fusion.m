classdef dp_node_segm_brats_fusion < dp_node

    % xxx: prototype

    methods

        % construct names of output files
        function output = i2o(obj, input)

            output.segfusion_simple_fn = fullfile(input.op, 'segfusionsimple.nii.gz');
            output.segfusion_mav_fn = fullfile(input.op, 'segfusionmav.nii.gz');

        end

        function output = execute(obj, input, output)
            % run a python script here
            % either directly from BRATS or an intermediator
            % pull from previous project
        end
    end
end