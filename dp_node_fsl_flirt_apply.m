classdef dp_node_fsl_flirt_apply < dp_node

    % coregistration using flirt

    methods

        function output = i2o(obj, input)
            output.nii_fn = msf_fn_new_path(input.op, msf_fn_append(input.nii_fn, '_flirt'));
        end

        function output = execute(obj, input, output)

            % Build the flirt command 
            flirt_cmd = sprintf('flirt -in %s -ref %s -out %s -init %s -applyxfm', ...
                                input.nii_fn, input.target_fn, ...
                                output.nii_fn, input.matrix_fn);

            msf_mkdir(fileparts(output.nii_fn));

            system(flirt_cmd); % Execute the flirt command
        end
    end
end