classdef dp_node_elastix_apply < dp_node

    % expected input
    %
    % nii_fn
    % elastix_t_fn
    %
    % output
    %
    % nii_fn

    properties
        mio_opt = mio_opt();
    end


    methods

        function obj = dp_node_elastix_apply(mio_opt)
            if (nargin > 0), obj.mio_opt = mio_opt; end

            obj.input_spec.add('nii_fn', 'file', 1, 1, 'The nifti file to be transformed');
            obj.input_spec.add('elastix_t_fn', 'file', 1, 1, 'Transform specification');

        end

        function output = i2o(obj, input, output)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_trans');
        end

        function output = execute(obj, input, output)

            [I_in, h] = mdm_nii_read(input.nii_fn);

            t = elastix_p_read(input.elastix_t_fn);

            [I_out, h_out] = mio_transform(I_in, t, h, obj.opt);
            mdm_nii_write(I_out, output.nii_fn, h_out);

        end

    end
end