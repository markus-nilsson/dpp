classdef p6_mask < dp_node

    methods

        function obj = p6_mask()
            bp = '/media/fuji/MyBook1/BOF130_APTw/data/seg'; % t1 space
            obj.previous_node = p0_list_subjects(bp);
        end


        function input = po2i(obj, prev_output) % build input to this step from previous output
            input.bp = prev_output.bp;
            ip = fullfile(prev_output.bp, prev_output.id);
            input.t1_fn = fullfile(ip, 'raw_bet', 't1_bet_raw.nii.gz');
        end

        function output = i2o(obj, input)
            output.bp = input.bp; % keep the same base path

            op = fullfile(input.bp, input.id, 'dmri');

            output.nii_fn = fullfile(op, 'mask.nii.gz');

        end

        function output = execute(obj, input, output)

            % Read data
            [I, h] = mdm_nii_read(input.t1_fn);

            % Mask based on t1 mask

            M = I > 0;

            M = mio_mask_erode(M);
            M = mio_mask_erode(M);

            M = mio_mask_keep_largest(M);
            M = mio_mask_fill(M);

            M = mio_mask_expand(M);
            M = mio_mask_expand(M);

            mdm_nii_write(single(M), output.nii_fn, h);

        end
    end


end




