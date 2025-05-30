classdef dp_node_dmri_topup2 < dp_node_workflow

    % version 2 of our implementation, uses the standard FSL topup

    methods

        function obj = dp_node_dmri_topup2(do_apply)

            if (nargin < 1), do_apply = 1; end

            a = dp_node_dmri_topup2_io();
            b = dp_node_dmri_topup2_prep();
            c = dp_node_dmri_topup2_b0();
            d = dp_node_dmri_topup2_apply();

            nodes = {a,b,c,d};

            % running apply topup is opitonal (but default)
            if (~do_apply)
                nodes = nodes(1:3);
            end

            obj = obj@dp_node_workflow(nodes);
            
        end
        
    end
end