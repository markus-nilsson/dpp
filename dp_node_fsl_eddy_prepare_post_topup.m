classdef dp_node_fsl_eddy_prepare_post_topup < dp_node_fsl_eddy_prepare

    % this assumes we are working on a data set with full data in
    % the ap direction, with topup performed prior to this

    methods

        function output = i2o(obj, input)
            output = i2o@dp_node_fsl_eddy_prepare(obj, input);
            output.acqp_fn = input.topup_spec_fn;  

            output.topup_data_path = input.topup_data_path;
        end

    end

end