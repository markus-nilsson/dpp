classdef dp_node_segm_simple_bet < dp_node

    % simple brain extraction 
    
    methods

        function obj = dp_node_segm_simple_bet()
            obj.output_test = {'nii_fn', 'mask_fn'};
        end
    
        function output = i2o(obj, input)
            output.mask_fn = dp.new_fn(input.op, input.nii_fn, '_mask');
            output.nii_fn  = dp.new_fn(input.op, input.nii_fn, '_simplebet');
        end

        function output = execute(obj, input, output)

            % simple mask creation
            [I,h] = mdm_nii_read(input.nii_fn);

            M = max(double(I),[], 4);
            M = M > 0.5 * quantile(M(:), 0.95);
            M = mio_mask_erode(M, 1);
            M = mio_mask_expand(M, 2);
            M = mio_mask_keep_largest(M);
            M = mio_mask_fill(M);

            Q = mean(I,4);

            th(1) = quantile(Q(M(:) == 0), 0.9);
            th(2) = quantile(Q(M(:) == 1), 0.1);

            th = mean(th);

            M = Q > th;
            M = mio_mask_keep_largest(M);
            M = mio_mask_fill(M);

            mdm_nii_write(single(M), output.mask_fn, h);
            mdm_nii_write(Q .* M, output.nii_fn, h);
                       
        end
    end
end