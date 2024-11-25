classdef dp_node_dmri_smooth < dp_node_dmri

    % gaussian smoothing

    properties
        filter_sigma = 0.6;
    end

    methods

        function obj = dp_node_dmri_smooth(filter_sigma)

            if (nargin > 0), obj.filter_sigma = filter_sigma; end

        end

        function output = i2o(obj, input)

            % Pass information about the dmri and mask fns, if available
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_s');

            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);
            
        end

        function output = execute(obj, input, output)


            [I,h] = mdm_nii_read(input.dmri_fn);

            I = mio_smooth_4d(I, obj.filter_sigma);

            mdm_nii_write(I, output.dmri_fn, h);

            xps = mdm_xps_load(input.xps_fn);
            mdm_xps_save(xps, output.xps_fn);

        end

    end
end