classdef dp_node_fsl_eddy < dp_node_workflow

    % basic implementation so far: assume we have 
    % no topup, a single file, no special options

    methods

        function obj = dp_node_fsl_eddy()

            a = dp_node_fsl_eddy_prepare;
            b = dp_node_fsl_eddy_run;

            obj = obj@dp_node_workflow({a,b});

        end

    end

end


