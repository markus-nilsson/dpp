classdef dp_node_md < dp_node

    % Calculates mean diffusivity (MD) maps from diffusion-weighted images. Performs
    % linear fitting to estimate apparent diffusion coefficients within specified b-value ranges.

    properties

        % defaults for mdt mapping
        b_min = 1.4e9;
        b_max = 2.6e9;
        b_delta = 0;
        name = 'MDT';

        opt = struct('filter_sigma', 0.5);

    end

    methods

        function output = i2o(obj, input)

            op = msf_fileparts(input.nii_fn);

            output.bp = input.bp;
            output.op = op;
            output.md_fn = fullfile(output.op, [obj.name '.nii.gz']);
            1;
        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.nii_fn);
            xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(input.nii_fn));


            if (obj.opt.filter_sigma > 0)
                I = mio_smooth_4d(I, obj.opt.filter_sigma);
            end

            ind = ...
                (xps.b > obj.b_min) & ...
                (xps.b < obj.b_max) & ...
                (abs(xps.b_delta - obj.b_delta) < 0.01);

            X = [ones(sum(ind), 1) xps.b(ind) * 1e-9];

            g = @(x)reshape(x(:,:,:,ind), prod(size(I,1,2,3)), sum(ind));

            M = log(abs(g(double(I)))) * X * inv(X' * X);

            M = reshape(M, [size(I,1,2,3) 2]);

            MD = -M(:,:,:,2);

            MD(MD < 0) = 0;
            MD(MD > 4) = 4;

            if (~isempty(input.mask_fn))
                mask = mdm_nii_read(input.mask_fn);
                MD = MD .* double(mask);
            end

            mdm_nii_write(MD, output.md_fn, h);

        end
    end
end




