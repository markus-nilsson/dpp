classdef dp_node_dmri_subsample < dp_node

    % subsamples a dmri sequence given an xps function

    properties
        xps_fun;
        suffix;
    end

    methods

        function obj = dp_node_dmri_subsample(xps_fun, suffix)
            obj.xps_fun = xps_fun;
            obj.suffix = suffix;
        end

        function output = i2o(obj, input)
            output.dmri_fn = msf_fn_new_path(input.op, ...
                msf_fn_append(input.dmri_fn, obj.suffix));
        end

        function output = execute(obj, input, output)

            [I,h] = mdm_nii_read(input.dmri_fn);
            xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(input.dmri_fn));

            ind = obj.xps_fun(xps);

            I = I(:,:,:,ind);

            xps = mdm_xps_subsample(xps, ind);

            mdm_nii_write(I, output.dmri_fn, h);

            mdm_xps_save(xps, mdm_xps_fn_from_nii_fn(output.dmri_fn));

        end
    end
end