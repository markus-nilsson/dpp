classdef dp_node_dmri_denoise < dp_node_dmri

    % Denoises diffusion MRI data using MRtrix's dwidenoise tool. Reduces noise
    % while preserving signal integrity using principal component analysis.

    methods

        function obj = dp_node_dmri_denoise()
            obj.input_test = {'dmri_fn', 'xps_fn'};
            obj.output_test = {'dmri_fn', 'xps_fn'};
            
            obj.input_spec.add('dmri_fn', 'file', 1, 1, 'Diffusion MRI nifti file');
        end

        function output = i2o(obj, input) %#ok<INUSD>
            
            output.dmri_fn = dp.new_fn(input.op, input.dmri_fn, '_dn');
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);
            
        end

        function output = execute(obj, input, output) %#ok<INUSD>

            % execute mrtrix denoising (linux version here, remove &> .. to debug
            cmd = sprintf('dwidenoise %s %s &> /dev/null', input.dmri_fn, output.dmri_fn);
            msf_delete(output.dmri_fn);
            msf_mkdir(fileparts(output.dmri_fn));
            msf_system(cmd);

            % copy the xps from the original data 
            % (if this dataset has xps's)
            xps_fn = mdm_xps_fn_from_nii_fn(input.dmri_fn);

            xps = mdm_xps_load(xps_fn);
            mdm_xps_save(xps, output.xps_fn);

        end

    end

end


