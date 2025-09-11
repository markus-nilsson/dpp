classdef dp_node_segm_brats_prepare < dp_node

    % requires a conda env "brats2023" set up according to brainles
    % instructions

    methods

        function obj = dp_node_segm_brats_prepare()
            obj.conda_env = 'brats2023';

            obj.input_spec.add('t1_fn', 'file', 1, 1, 'T1-weighted nifti file');
            obj.input_spec.add('t1c_fn', 'file', 1, 1, 'T1-weighted post contrast nifti file');
            obj.input_spec.add('t2_fn', 'file', 1, 1, 'T2-weighted nifti file');
            obj.input_spec.add('flair_fn', 'file', 1, 1, 'FLAIR nifti file');
        end

        % construct names of output files
        function output = i2o(obj, input)

            nii_path = fullfile(input.op, 'normalized_bet');

            output.t1_fn = fullfile(nii_path, 't1_bet_normalized.nii.gz');
            output.t1c_fn = fullfile(nii_path, 't1c_bet_normalized.nii.gz');
            output.t2_fn = fullfile(nii_path, 't2_bet_normalized.nii.gz');
            output.flair_fn = fullfile(nii_path, 'fla_bet_normalized.nii.gz');

        end

        function output = execute(obj, input, output)

            % run python script

            cmd = sprintf(['python3 %s/tumseg_fn_prepare.py ' ...
                '%s ' ...
                '"%s" ' ...
                '"%s" ' ...
                '"%s" ' ...
                '"%s" '], ...
                fileparts(mfilename('fullpath')), ...
                output.op, ...
                input.t1_fn, ...
                input.t1c_fn, ...
                input.t2_fn, ...
                input.flair_fn);

            [s, r] = obj.syscmd(cmd);


        end
    end
end

