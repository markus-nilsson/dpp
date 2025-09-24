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
             
            obj.input_spec.add('nii_fn', 'file', 1, 1, 'File to transform (nii)');
            obj.input_spec.add('elastix_t_fn', 'file', 1, 1, 'Transform parameter file (txt)');

            obj.output_spec.add('nii_fn', 'file', 1, 1, 'Transformed file (nii)');
            
        end

        function output = i2o(obj, input, output)
            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_trans');
        end

        function output = execute(obj, input, output)

            [I_in, h] = mdm_nii_read(input.nii_fn);

            t = elastix_p_read(input.elastix_t_fn);

            % May need to build this one out
            switch (t.ResultImagePixelType)
                case '"float"'
                    f = @(x) single(x); 
                otherwise
                    f = @(x) x;
            end

            [I_out, h_out] = mio_transform(f(I_in), t, h, obj.opt);

            h_out.data_type =  h.data_type;
            h_out.bitpix = h.bitpix;
            mdm_nii_write(cast(I_out, 'like', I_in), output.nii_fn, h_out);

        end

    end
end