classdef dp_node_dmri_preprocess_hardi < dp_node_workflow

    % Standard HARDI preprocessing pipeline for BioFinder2 workflows. Combines brain extraction,
    % eddy current correction, denoising, and topup distortion correction for high-quality diffusion data.

    methods
        

        function obj = dp_node_dmri_preprocess_hardi()

            % expecting ap to be main acquisition
            a = dp_node_io('dmri_fn', 'nii_ap_fn');
            b = dp_node_dmri_bet();             
            c = dp_node_fsl_eddy_prepare();
            d = dp_node_dmri_denoise();
            e = dp_node_fsl_eddy();
            f = dp_node_io_rename({...
                {'nii_ap_fn', 'dmri_fn'}, ...
                {'nii_pa_fn', 'nii_pa_fn'}});
            g = dp_node_dmri_topup();

            b.do_i2o_pass = 1;
            c.do_i2o_pass = 1;
            d.do_i2o_pass = 1;
            e.do_i2o_pass = 1;

            obj = obj@dp_node_workflow({a,b,c,d,e,f,g});            

        end

    end

    

end