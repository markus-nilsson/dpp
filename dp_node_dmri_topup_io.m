classdef dp_node_dmri_topup_io < dp_node

    % this is to help test and build inputs to topup

    methods

        function obj = dp_node_dmri_topup_io()

            % help the user with good error messages
            obj.input_test = {'nii_ap_fn', 'nii_pa_fn'};
            
            % disable the execution
            obj.get_dpm('execute').do_run_execute = 0;

        end

    end

end