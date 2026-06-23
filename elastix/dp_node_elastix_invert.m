classdef dp_node_elastix_invert < dp_node

    % invert elastix coregistration
    %
    % input fields
    %
    % elastix_t_fn
    %
    % output fields
    %
    % elastix_t_fn (registration parameters)
    %

    properties
        p = elastix_p_6dof(100);
        mio_opt = mio_opt();
    end


    methods

        function obj = dp_node_elastix_invert(p, mio_opt)

            if (nargin >= 1), obj.p = p; end
            if (nargin >= 2), obj.mio_opt = mio_opt; end
            
            obj.input_test = {'nii_fn', 'elastix_t_fn'};
            obj.output_test = {'elastix_t_fn'};


            % from manual:
            % The DisplacementMagnitudePenalty is a cost function that penalises ||Tμ(x) − x||2. You can use this
            % to invert transforms, by setting the transform to be inverted as an initial transform (using -t0), setting
            % (HowToCombineTransforms "Compose"), and running elastix with this metric, using the original fixed
            % image set both as fixed (-f) and moving (-m) image. After that you can manually set the initial transform
            % in the last parameter file to "NoInitialTransform", and voila, you have the inverse transform! Strictly
            % speaking, you should then also change the Size/Spacing/Origin/Index/Direction settings to match that of
            % the moving image. Select it with:
            % (Metric "DisplacementMagnitudePenalty")
            % Note that inverting a transformation becomes conceptually very similar to performing an image registration
            % in this way. Consequently, the same choices are relevant: optimisation algorithm, multiresolution etc...

            obj.p.HowToCombineTransforms = 'Compose';
            obj.p.Metric = 'DisplacementMagnitudePenalty';


        end

        function output = i2o(obj, input, output)
            output.elastix_t_fn = dp.new_fn(input.op, input.nii_fn, '_reginv', '.txt');
        end

        function output = execute(obj, input, output)


            [I_mov, h_mov] = mdm_nii_read(input.nii_fn);

            t0 = elastix_p_read(input.elastix_t_fn);

            [I_res,tp,h_res,elastix_t] = mio_coreg(I_mov, I_mov, obj.p, ...
                obj.mio_opt, h_mov, h_mov, t0);

            elastix_t.InitialTransformParameterFileName = 'NoInitialTransform';

            elastix_p_write(elastix_t, output.elastix_t_fn);
            % elastix_p_write(obj.p, output.elastix_p_fn);

        end
    end
end