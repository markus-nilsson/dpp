classdef dp_node_fsl_eddy < dp_node_workflow

    % basic implementation so far: assume we have 
    % no topup, a single file, no special options

    methods

        function obj = dp_node_fsl_eddy(is_post_topup)

            if (nargin == 0), is_post_topup = 0; end

            if (is_post_topup)
                a = dp_node_fsl_eddy_prepare_post_topup;
            else
                a = dp_node_fsl_eddy_prepare;
            end

            b = dp_node_fsl_eddy_run;

            obj = obj@dp_node_workflow({a,b});

        end

    end

end


