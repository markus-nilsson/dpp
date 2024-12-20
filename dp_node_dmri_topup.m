classdef dp_node_dmri_topup < dp_node_workflow

    methods

        function obj = dp_node_dmri_topup()

            a = dp_node_dmri_topup_io();
            b = dp_node_dmri_topup_prep();
            c = dp_node_dmri_topup_b0();
            d = dp_node_dmri_topup_apply();

            obj = obj@dp_node_workflow({a,b,c,d});
            
        end
        
    end
end