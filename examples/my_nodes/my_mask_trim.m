classdef my_mask_trim < dp_node

    methods

        function output = i2o(obj, input)

            output = input;
            output.mask_fn = dp.new_fn(input.op, input.mask_fn, '_trim');


            output.fa_fn = dp.new_fn(input.op, input.fa_fn, '_trim');
            output.md_fn = dp.new_fn(input.op, input.md_fn, '_trim');
            output.rd_fn = dp.new_fn(input.op, input.rd_fn, '_trim');
            output.ad_fn = dp.new_fn(input.op, input.ad_fn, '_trim');
            output.s0_fn = dp.new_fn(input.op, input.s0_fn, '_trim');
            

        end

        function output = execute(obj, input, output)

            % Load, trim, save the mask
            [M,h] = mdm_nii_read(input.mask_fn);

            f = @(x,a,b) mio_smooth_4d(double(x), a) > b;
            M = f(f(f(M, 0.7, 0.3), 0.75, 0.8), 0.7, 0.85);
            M = f(M, 0.7, 0.8);

            mdm_nii_write(double(M), output.mask_fn, h);            

            % Trim parameter maps

            s = {'fa_fn', 'md_fn', 'ad_fn', 'rd_fn', 's0_fn'};

            for c = 1:numel(s)

                [I,h] = mdm_nii_read(input.(s{c}));
                IM = medfilt3(I);

                if (c == 1)
                    ind = mio_smooth_4d(double(I - IM), 0.5) > 0.15;
                end

                I(ind) = IM(ind);

                mdm_nii_write(I.*M, output.(s{c}), h);
            end
        end


    end

end