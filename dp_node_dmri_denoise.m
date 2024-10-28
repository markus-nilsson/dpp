classdef dp_node_dmri_denoise < dp_node

    % runs dwidenosie from mrtix

    methods

        function output = i2o(obj, input)
            output.dmri_fn = msf_fn_append(input.dmri_fn, '_dn');
        end

        function output = execute(obj, input, output)

            % execute mrtrix denoising (linux version here, remove &> .. to debug
            cmd = sprintf('dwidenoise %s %s &> /dev/null', input.dmri_fn, output.dmri_fn);
            msf_delete(output.dmri_fn);
            msf_system(cmd);

            % copy the xps from the original data (if this dataset has
            % xps's)
            xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);

            if (exist(xps_fn, 'file'))
                xps = mdm_xps_load(xps_fn);
                mdm_xps_save(xps, mdm_xps_fn_from_nii_fn(output.dmri_fn));
            end

        end

    end

end


