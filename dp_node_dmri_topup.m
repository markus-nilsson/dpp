classdef dp_node_dmri_topup < dp_node_workflow

    methods

        function obj = dp_node_dmri_topup()

            a = dp_node_dmri_topup_prep();
            b = dp_node_dmri_topup_b0();
            c = dp_node_dmri_topup_apply();

            obj = obj@dp_node_workflow({a,b,c});
            
        end
        
    end
end