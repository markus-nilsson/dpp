classdef dp_node_dmri_normalise_seq < dp_node_dmri

    % normalize b0 across sequences

    methods
    
        function obj = dp_node_dmri_normalise_seq()
            obj.output_test = {'dmri_fn', 'xps_fn'};
        end

        function output = i2o(obj, input)

            % Pass information about the dmri and mask fns, if available
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_normseq');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            if (isfield(input, 'mask_fn')), output.mask_fn = input.mask_fn; end

        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.dmri_fn);
            xps = mdm_xps_load(input.xps_fn);

            M = mdm_nii_read(input.mask_fn);

            if (~isfield(xps, 's_ind'))
                error('we need s_nid here');
            end
           
            n_seq = max(xps.s_ind);

            if (n_seq == 1)
                error('no need to apply this node, aborting');
            end

            for c_seq = 1:n_seq

                b0_ind = (xps.b < 10e6) & (xps.s_ind == c_seq);

                if (sum(b0_ind) == 0)
                    error('no b0 found for seq %i, aborting', c_seq);
                end

                if (c_seq == 1)
                    b0_ref = mean(I(:,:,:, b0_ind), 4);
                    b0_floor = 0.05 * quantile(b0_ref(M(:) > 0), 0.05);
                    continue;
                end

                tmp = mean(I(:,:,:, b0_ind), 4);

                B = sqrt(tmp.^2 + b0_floor.^2) ./ sqrt(b0_ref.^2 + b0_floor.^2);
                B = medfilt3(B);
                B = mio_smooth_4d(B, 0.7);

                ind = find(xps.s_ind == c_seq);
                for c = 1:numel(ind)
                    I(:,:,:,ind(c)) = I(:,:,:,ind(c)) ./ B;
                end

                % verify
                if (1)
                    tmp2 = mean(I(:,:,:, b0_ind), 4);
                end

            end

            mdm_nii_write(I, output.dmri_fn, h);
            mdm_xps_save(xps, output.xps_fn);





        end

    end
end