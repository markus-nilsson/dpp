classdef dp_node_segm_brats < dp_node_segm

    % turn this into a workflow node later

    methods

        % construct names of output files
        function output = i2o(obj, input)

            % mav or simple is the choice here

            output.labels_fn = fullfile(input.op, 'segfusionmav.nii.gz');

            output.t1_fn = fullfile(input.op, 'normalized_bet', 't1_bet_normalized.nii.gz');
            output.t2_fn = fullfile(input.op, 'normalized_bet', 't2_bet_normalized.nii.gz');
            output.t1c_fn = fullfile(input.op, 'normalized_bet', 't1c_bet_normalized.nii.gz');
            output.flair_fn = fullfile(input.op, 'normalized_bet', 'fla_bet_normalized.nii.gz');
            
        end

        function output = execute(obj, input, output)
            % run a python script here
            % either directly from BRATS or an intermediator
            % pull from previous project
        end
    end

    methods (Hidden)

        function [labels, ids] = segm_info(obj)

            labels = {'Tumor', 'Odema', 'CE', 'Tumor incl CE'};
            ids    = {1, 2, 4, [1 4]};

        end

    end
end