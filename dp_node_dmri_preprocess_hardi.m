classdef dp_node_dmri_preprocess_hardi < dp_node_workflow

    % holder of biofinder2 standard workflow

    methods
        

        function obj = dp_node_dmri_preprocess_hardi()

            % expecting ap to be main acquisition
            a = dp_node_io('dmri_fn', 'nii_ap_fn');
            b = dp_node_dmri_denoise();
            c = dp_node_dmri_mec_eb();
            d = dp_node_io_rename({...
                {'nii_ap_fn', 'dmri_fn'}, ...
                {'nii_pa_fn', 'nii_pa_fn'}});
            e = dp_node_dmri_topup();

            b.do_i2o_pass = 1;
            c.do_i2o_pass = 1;

            obj = obj@dp_node_workflow({a,b,c,d,e});            

            obj.input_fields = {'nii_ap_fn', 'nii_pa_fn'};

        end

    end

    

end