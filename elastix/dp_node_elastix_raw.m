classdef dp_node_elastix_raw < dp_node

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

        function obj = dp_node_elastix_raw(p, mio_opt)
            
            if (nargin >= 1), obj.p = p; end
            if (nargin >= 2), obj.mio_opt = mio_opt; end

            obj.output_test = {'nii_fn', 'elastix_t_fn'};
        end

        function output = i2o(obj, input, output)

            output.nii_fn = dp.new_fn(input.op, input.nii_fn, '_elastix');
            output.elastix_t_fn = dp.new_fn(input.op, input.nii_fn, '_elastix', '.txt');

            % target passthrough
            output.target_fn = input.target_fn;

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
            
        end

        function output = execute(obj, input, output)

            % Setup structur
            input.p_fn = elastix_p_write(obj.p, fullfile(output.tmp.bp, 'p.txt'));
            
            if ~isfield(input, 't0_fn'), input.t0_fn = ''; end
            if ~isfield(input, 'nii_mask_fn'), input.nii_mask_fn = ''; end
            if ~isfield(input, 'target_mask_fn'), input.target_mask_fn = ''; end
            
            % Run registration
            [res_fn, tp_fn] = elastix_run_elastix(...
                input.nii_fn, ...
                input.target_fn, ...
                input.p_fn, ...
                input.op, ...
                input.t0_fn, ...
                input.nii_mask_fn, ...
                input.target_mask_fn);

            % Manage output
            msf_mkdir(output.op);
            msf_delete(output.nii_fn); 
            msf_delete(output.elastix_t_fn);

            [I,h] = mdm_nii_read(res_fn);
            mdm_nii_write(I, output.nii_fn, h);

            copyfile(tp_fn, output.elastix_t_fn);


        end

    end
end