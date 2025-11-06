classdef dp_node_dmri_topup2_io < dp_node

    % Input/output handler for TOPUP2 processing workflows. Validates file paths and prepares
    % datasets with enhanced parameter checking for the improved TOPUP implementation.

    methods

        function obj = dp_node_dmri_topup2_io()

            % help the user with good error messages
            obj.input_test = {...
                'ap_dmri_fn', 'pa_dmri_fn', ...
                'ap_json_fn', 'pa_json_fn', ...
                'ap_xps_fn', 'pa_xps_fn'};
            
            obj.input_spec.add('ap_dmri_fn', 'file', 1, 1, 'Anterior-posterior diffusion MRI nifti file');
            obj.input_spec.add('pa_dmri_fn', 'file', 1, 1, 'Posterior-anterior diffusion MRI nifti file');
            obj.input_spec.add('ap_json_fn', 'file', 1, 1, 'Anterior-posterior JSON parameter file');
            obj.input_spec.add('pa_json_fn', 'file', 1, 1, 'Posterior-anterior JSON parameter file');
            obj.input_spec.add('ap_xps_fn', 'file', 1, 1, 'AP experimental parameter set file');
            obj.input_spec.add('pa_xps_fn', 'file', 1, 1, 'PA experimental parameter set file');
            
            % disable the execution
            obj.get_dpm('execute').do_run_execute = 0;

        end

    end

end