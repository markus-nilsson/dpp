classdef dp_node_dmri_preprocess_hardi_v2 < dp_node_workflow

    % Enhanced HARDI preprocessing pipeline (version 2) for BioFinder2 workflows. Improved
    % processing order with updated topup integration for better distortion correction performance.


    methods
        

        function obj = dp_node_dmri_preprocess_hardi_v2()

            % expecting ap to be main acquisition

            a = dp_node_dmri_topup2(0);

            b = dp_node_dmri_preprocess_set_defaults('ap_dmri_fn'); b.do_i2o_pass = 1;

            c = dp_node_dmri_bet();     c.do_i2o_pass = 1;       
            d = dp_node_dmri_denoise(); d.do_i2o_pass = 1;
            e = dp_node_fsl_eddy(1);

            obj = obj@dp_node_workflow({a,b,c,d,e});            

        end

    end

end