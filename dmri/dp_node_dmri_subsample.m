classdef dp_node_dmri_subsample < dp_node

    % Subsamples diffusion MRI sequences based on user-defined criteria. Extracts specific
    % volumes or directions from the dataset using custom selection functions.

    properties
        xps_fun;
        suffix;
    end

    methods

        function obj = dp_node_dmri_subsample(xps_fun, suffix)
            obj.xps_fun = xps_fun;
            obj.suffix = suffix;

            if (suffix(1) ~= '_'), warning('probably want _suffix'); end

            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Input diffusion volumes (nii)');
            obj.input_spec.add('xps_fn', 'file', 0, 0 , 'Experimental parameter structure (may be inferred from dmri_fn)');
        end

        function output = i2o(obj, input)
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, obj.suffix);
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);
        end

        function output = execute(obj, input, output)

            if (~isfield(input, 'xps_fn'))
                input.xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);
            end

            [I,h] = mdm_nii_read(input.dmri_fn);
            xps = mdm_xps_load(input.xps_fn); 

            ind = obj.xps_fun(xps);

            if (isempty(ind) || (sum(ind) == 0))
                error('no data fulfils filter');
            end

            I = I(:,:,:,ind);

            xps = mdm_xps_subsample(xps, ind);

            mdm_nii_write(I, output.dmri_fn, h);

            mdm_xps_save(xps, output.xps_fn);

        end
    end
end