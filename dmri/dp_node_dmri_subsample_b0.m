classdef dp_node_dmri_subsample_b0 < dp_node_dmri

    % Extracts and subsamples b0 (non-diffusion-weighted) images from diffusion MRI data.
    % Creates a reduced dataset containing only the reference images for processing workflows.

    % subsamples the b0 of a dmri sequence 

    % input
    % dmri_fn
    % xps_fn

    % output
    % nii_fn

    methods

        function output = i2o(obj, input)

            output.nii_fn = dp.new_fn(input.op, input.dmri_fn, '_b0');
    
        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.dmri_fn);
            xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(input.dmri_fn));

            % find the data with low b-values
            ind = xps.b <= min(xps.b);

            I = mean(I(:,:,:,ind), 4);

            mdm_nii_write(I, output.nii_fn, h);

        end
    end
end