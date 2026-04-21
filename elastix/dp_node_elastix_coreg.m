classdef dp_node_elastix_coreg < dp_node

    % coregistration using elastix
    % 
    % input fields
    % 
    % nii_fn
    % target_fn
    %
    % output fields
    %
    % nii_fn (registered file)
    % elastix_f_fn (registration parameters)
    % target_fn (same as input)
    %

    properties
        p = elastix_p_6dof(100);
        mio_opt = mio_opt();
    end
    

    methods

        function obj = dp_node_elastix_coreg(p, mio_opt)
            
            if (nargin >= 1), obj.p = p; end
            if (nargin >= 2), obj.mio_opt = mio_opt; end

            obj.output_test = {'nii_fn', 'elastix_t_fn'};
        end

        function output = i2o(obj, input, output)

            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_ecoreg');
            output.elastix_t_fn = dp.new_fn(input.op, input.nii_fn, '_ecoreg', '.txt');
            output.elastix_p_fn = dp.new_fn(input.op, input.nii_fn, '_p', '.txt');

            % target passthrough
            output.target_fn = input.target_fn;
        end

        function output = execute(obj, input, output)

            % assume input.nii_fn is a 3D volume

            [I_mov, h_mov] = mdm_nii_read(input.nii_fn);
            [I_ref, h_ref] = mdm_nii_read(input.target_fn);


            [I_res,tp,h_res,elastix_t] = mio_coreg(I_mov, I_ref, obj.p, ...
                obj.mio_opt, h_mov, h_ref);

            % Store also nifti header info in the transform parameters
            elastix_t.A_mov = [h_mov.srow_x; h_mov.srow_y; h_mov.srow_z]';
            elastix_t.A_ref = [h_ref.srow_x; h_ref.srow_y; h_ref.srow_z]';

            mdm_nii_write(I_res, output.nii_fn, h_res);

            elastix_p_write(elastix_t, output.elastix_t_fn);
            elastix_p_write(obj.p, output.elastix_p_fn);

        end

    end
end