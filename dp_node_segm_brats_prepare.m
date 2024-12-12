classdef dp_node_segm_brats_prepare < dp_node

    % xxx: this node has not been sufficiently tested

    methods

        % construct names of output files
        function output = i2o(obj, input)

            nii_path = fullfile(input.bp, input.id, 'normalized_bet');

            output.t1_fn = fullfile(nii_path, 't1_bet_normalized.nii.gz');
            output.t1c_fn = fullfile(nii_path, 't1c_bet_normalized.nii.gz');
            output.t2_fn = fullfile(nii_path, 't2_bet_normalized.nii.gz');
            output.flair_fn = fullfile(nii_path, 'fla_bet_normalized.nii.gz');

            % not sure this is where we should have something like this, but
            % put it here for now

            log_path = fullfile(output.bp, input.id, 'co-registration');

            if (~exist(log_path, 'dir')), return; end

            log_t1_fn = fullfile(log_path, 'co__t1c__t1.log');
            log_t2_fn = fullfile(log_path, 'co__t1c__t2.log');
            log_flair_fn = fullfile(log_path, 'co__t1c__flair.log');

            % check if logs indicate we have changed files since last run
            [~,fixed_current_name] = msf_fileparts(input.t1c_fn);
            log_fn = {log_t1_fn, log_t2_fn, log_flair_fn};
            mov_fn = {input.t1_fn, input.t2_fn, input.flair_fn};

            is_changed = 0;
            for c = 1:3
                txt = mdm_txt_read(log_fn{c});

                f = @(x) x( (2+find(x == ':', 1 ,'first')):end);
                fixed_fn = f(txt{3});
                moving_fn = f(txt{4});

                [~,fixed_name] = msf_fileparts(fixed_fn);
                [~,moving_name] = msf_fileparts(moving_fn);

                if (~strcmp(fixed_name, fixed_current_name))
                    is_changed = 1;
                end

                [~,moving_current_name] = msf_fileparts(mov_fn{c});

                if (~strcmp(moving_name, moving_current_name))
                    is_changed = 1;
                end

            end

            % Delete the whole segmentation folder if base data is changed
            seg_path = fullfile(output.bp, input.id);

            if (is_changed)
                warning('here lies dragons!')
                % msf_delete(seg_path);
            end

        end

        function output = execute(obj, input, output)

            % run python script

            cmd = sprintf('python3 tumseg_fn_prepare.py %s %s %s %s %s', ...
                output.op, ...
                input.t1_fn, ...
                input.t1c_fn, ...
                input.t2_fn, ...
                input.flair_fn);

            msf_system(cmd);

        end
    end
end