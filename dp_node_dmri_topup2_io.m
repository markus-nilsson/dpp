classdef dp_node_dmri_topup2_io < dp_node

    % this is to help test and build inputs to topup

    methods

        function obj = dp_node_dmri_topup2_io()

            % help the user with good error messages
            obj.input_test = {...
                'ap_dmri_fn', 'pa_dmri_fn', ...
                'ap_json_fn', 'pa_json_fn', ...
                'ap_xps_fn', 'pa_xps_fn'};
            
            % disable the execution
            obj.get_dpm('execute').do_run_execute = 0;

        end

    end

end