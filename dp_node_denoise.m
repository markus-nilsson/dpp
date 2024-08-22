classdef dp_node_denoise < dp_node

    methods

        function output = i2o(obj, input)
            output.bp = input.bp; % keep the same base path

            op = fullfile(input.bp, input.id);
            [~, name, ext] = msf_fileparts(input.nii_fn);

            output.nii_fn = fullfile(op, [name '_dn' ext]);

        end

        function output = execute(obj, input, output)

            % execute mrtrix denoising (linux version here, remove &> .. to debug
            cmd = sprintf('dwidenoise %s %s &> /dev/null', input.nii_fn, output.nii_fn);
            msf_delete(output.nii_fn);
            msf_system(cmd);

            % copy the xps from the original data
            xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(input.nii_fn));
            mdm_xps_save(xps, mdm_xps_fn_from_nii_fn(output.nii_fn));

        end

    end

end


