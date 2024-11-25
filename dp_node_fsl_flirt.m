classdef dp_node_fsl_flirt < dp_node

    % coregistration using flirt
    %
    % expecting
    % 
    % input.nii_fn
    % input.target_fn
    %
    % yields
    %
    % output.nii_fn
    % output.matrix_fn
    % output.target_fn

    methods

        function obj = dp_node_fsl_flirt()
            obj.output_test = {'nii_fn', 'matrix_fn'};
        end

        function output = i2o(obj, input)
            output.nii_fn = fullfile(input.op, 'fa_registered.nii.gz');
            output.matrix_fn = fullfile(input.op, 'fa_to_template.mat');

            % Pass info about the target
            output.target_fn = input.target_fn;
            output.original_nii_fn = input.nii_fn;
            
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