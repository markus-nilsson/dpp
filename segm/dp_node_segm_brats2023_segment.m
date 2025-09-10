classdef dp_node_segm_brats2023_segment < dp_node_segm
    % https://github.com/BrainLesion/BraTS

    % uses a conda env 'brats2023' that has all necessary libs installed
    %  (see link above)

    % first execution can be length, because the model need to be
    % downloaded


    properties (SetAccess=private)
        segmenter   (1,1) string
        cuda_devices(1,1) string
        force_cpu   (1,1) logical
        script_name (1,1) string
    end

    properties (Constant)
        valid_segmenters = ["adult_pre","adult_post","africa","goat", ...
            "meningioma","metastases","pediatric"];
    end
    

    methods

        function obj = dp_node_segm_brats2023_segment(segmenter, cuda_devices, force_cpu, script_name)

            arguments
                segmenter    (1,1) string 
                cuda_devices (1,1) string = "0"
                force_cpu    (1,1) logical = false
                script_name  (1,1) string = "brats2023.py"
            end

            % manual validation against the constant
            if ~ismember(segmenter, obj.valid_segmenters)
                error('dp_node_segm_brats2023_segment:BadSegmenter', ...
                    'Unknown segmenter "%s". Valid options are: %s', ...
                    segmenter, strjoin(obj.valid_segmenters, ", "));
            end

            obj.segmenter    = segmenter;      % e.g. "adult_pre"
            obj.cuda_devices = cuda_devices;   % e.g. "0" or "0,1"
            obj.force_cpu    = force_cpu;      % true to force CPU
            obj.script_name  = script_name;    % python CLI filename
            obj.conda_env    = 'brats2023';
            obj.output_test  = {'labels_fn'};

        end

        function output = i2o(obj, input)
            output = input;
            output.labels_fn = fullfile(input.op, sprintf('segmentation_%s.nii.gz', obj.segmenter));
        end

        function output = execute(obj, input, output)

            tmp_fn = fullfile(msf_tmp_path(), sprintf('segm_%s.nii.gz', obj.segmenter));

            py_path = fullfile(fileparts(mfilename('fullpath')), obj.script_name);
            if obj.force_cpu
                device_part = "--cpu";
            else
                device_part = sprintf('--cuda-devices "%s"', obj.cuda_devices);
            end

            cmd_py = sprintf( ...
                'python3 "%s" "%s" --segmenter %s %s --t1 "%s" --t1c "%s" --t2 "%s" --flair "%s"', ...
                py_path, tmp_fn, obj.segmenter, device_part, ...
                input.t1_fn, input.t1c_fn, input.t2_fn, input.flair_fn);

            [~, ~] = obj.syscmd(cmd_py);
            copyfile(tmp_fn, output.labels_fn);
        end


    end

    methods (Hidden)
        function [labels, ids] = segm_info(~)
            labels = {'Tumor','Odema','CE','Tumor incl CE'};
            ids    = {1, 2, 3, [1 3]};
        end
    end
end

