classdef dp_node_fsl_flirt < dp_node

    % coregistration using flirt

    methods

        function output = i2o(obj, input)
            output.nii_fn = fullfile(input.op, 'fa_registered.nii.gz');
            output.matrix_fn = fullfile(input.op, 'fa_to_template.mat');

            % Pass info about the target
            output.target_fn = input.target_fn;
            
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            flirt_cmd = sprintf('flirt -in %s -ref %s -out %s -omat %s', ...
                                input.nii_fn, input.target_fn, ...
                                output.nii_fn, output.matrix_fn);

            msf_mkdir(fileparts(output.nii_fn));

            system(flirt_cmd); % Execute the flirt command
        end
    end
end