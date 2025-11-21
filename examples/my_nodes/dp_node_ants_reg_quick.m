classdef dp_node_ants_reg_quick < dp_node
    % antsRegistrationSyN.sh (moving = input.nii_fn, fixed = input.target_fn)
    % Outputs affine + forward/inverse warps in <input.op>

    properties
        options = '';   % include threads and preset here, e.g. ' ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=16 -t s'
    end

    methods

        function obj = dp_node_ants_reg_quick(options)
            if (nargin>0), obj.options = options; end
            obj.output_test = {'affine_fn','warp_fn','invwarp_fn','warped_fn'};

        end

        function output = i2o(obj, input)
            tmp = msf_fn_append(input.nii_fn, '_mni_');
            prefix = msf_fn_new_path(input.op, tmp);
            [pdir,pfx,~] = msf_fileparts(prefix);
            prefix = fullfile(pdir, pfx);                     % ANTs prefix base (no ext)

            output.prefix      = prefix;
            output.target_fn   = input.target_fn;
            output.affine_fn   = [prefix '0GenericAffine.mat'];
            output.warp_fn     = [prefix '1Warp.nii.gz'];
            output.invwarp_fn  = [prefix '1InverseWarp.nii.gz'];
            output.warped_fn   = [prefix 'Warped.nii.gz'];    % QC, remains in op
        end


        function output = execute(obj, input, output)
            % set threads and build the command
            thr  = feature('numcores');
            envp = sprintf('ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=%d', thr);

            % if user didn’t provide flags, default to symmetric registration (-t s)
            if isempty(strtrim(obj.options))
                flags = ' -t s';
            else
                flags = [' ' strtrim(obj.options)];
            end

            msf_mkdir(fileparts(output.warped_fn));


            % full SyN variant
            % cmd = sprintf('%s antsRegistrationSyN.sh -d 3 -f "%s" -m "%s" -o "%s"%s', ...
            %     envp, input.target_fn, input.nii_fn, output.prefix, flags);

            % quick SyN variant 
            cmd = sprintf('%s antsRegistrationSyNQuick.sh -d 3 -f "%s" -m "%s" -o "%s"%s', ...
                envp, input.target_fn, input.nii_fn, output.prefix, flags);


            % Always save ANTs output to log in the same folder
            log_fn = fullfile(fileparts(output.warped_fn), 'ants_registration.log');
            cmd = [cmd, sprintf(' > "%s" 2>&1', log_fn)];

            system(cmd);
        end

    end
end
