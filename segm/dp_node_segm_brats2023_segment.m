classdef dp_node_segm_brats2023_segment < dp_node_segm 
    
    % https://github.com/BrainLesion/BraTS

    % uses a conda env 'brats2023' that has all necessary libs installed
    %  (see link above)

    methods

        function obj = dp_node_segm_brats2023_segment()
            obj.conda_env = 'brats2023';
            obj.output_test = {'labels_fn'};
        end

        % construct names of output files
        function output = i2o(obj, input)
            %output.bp = input;
            output = input;
            output.labels_fn   = fullfile(input.op, 'segmentation.nii.gz');
        end

        function output = execute(obj, input, output)
           
            % dealing with docker issue
            tmp_fn = fullfile(msf_tmp_path(), 'segm.nii.gz');

            % run python script
            cmd = sprintf(['python3 %s/brats2023.py ' ...
                '%s ' ...
                '%s ' ...
                '%s ' ...
                '%s ' ...
                '%s '], ...
                fileparts(mfilename('fullpath')), ...
                tmp_fn, ...
                input.t1_fn, ...
                input.t1c_fn, ...
                input.t2_fn, ...
                input.flair_fn);

            [s, r] = obj.syscmd(cmd);

            copyfile(tmp_fn, output.labels_fn);
        end
    end


    methods (Hidden)

        function [labels, ids] = segm_info(obj)

            labels = {'Tumor', 'Odema', 'CE', 'Tumor incl CE'};
            ids    = {1, 2, 3, [1 3]};

        end

    end    
end









