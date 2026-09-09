classdef dp_node_dmri_eddy < dp_node_workflow_tmp

    % input: dmri_fn, xps_fn

    methods

        function obj = dp_node_dmri_eddy()

            a = dp_node_dmri_io_xps_to_bval_bvec();
            b = dp_node_dmri_subsample_b0().set('do_i2o_pass', 1);
            c = dp_node_segm_hd_bet().set('do_i2o_pass', 1);
            d = dp_node_fsl_eddy();
            
            obj = obj@dp_node_workflow_tmp({a,b,c,d}, ...
                'eddy', {'dmri_fn', 'xps_fn', 'parameters_fn'}, {}, 0);

        end
        
    end
end