classdef dp_node_fsl_flirt < dp_node

    % coregistration using flirt
    %
    % default use: template FA in a dMRI pipeline

    methods
    
        function obj = dp_node_fsl_flirt()
            obj@dp_node();
        end

        function input = po2i(obj, po)
            
            % Set default template from FSL if not provxided
            if (~isfield(po, 'target_fn') || isempty(po.target_fn))
                fsl_data_dir = getenv('FSLDIR'); % Get FSL directory from environment
                po.target_fn = fullfile(fsl_data_dir, 'data', 'standard', 'FMRIB58_FA_1mm.nii.gz');
            end

            input = po; % Pass the modified po to input
        end

        function output = i2o(obj, input)
            output.nii_fn = fullfile(input.op, 'fa_registered.nii.gz');
            output.matrix_fn = fullfile(input.op, 'fa_to_template.mat');
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            flirt_cmd = sprintf('flirt -in %s -ref %s -out %s -omat %s', ...
                                input.fa_fn, input.target_fn, ...
                                output.nii_fn, output.matrix_fn);

            system(flirt_cmd); % Execute the flirt command
        end
    end
end