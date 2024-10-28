classdef dp_node_dmri_topup_prep < dp_node

    methods
        
        function output = i2o(obj, input)

            % Pass on input to next node
            output = input;

            output.topup_nii_fn = fullfile(output, 'topupinput.nii.gz');
            output.topup_spec_fn = fullfile(output.op, 'topup.txt');
            output.topup_xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
            

        end

        function output = execute(obj, input, output)

            % define options
            opt = mdm_opt();

            % connect to data
            s_ap = mdm_s_from_nii(input.nii_ap_fn);
            s_pa = mdm_s_from_nii(input.nii_pa_fn);

            % define temporary working path, create output dir
            wp = output.tmp.bp;
            msf_mkdir(output.op);

            % Pull out the b0 / low b0 volumes
            s_pa_b0 = mdm_s_subsample(s_pa, s_pa.xps.b <= 0.11e9, wp, opt);
            s_ap_b0 = mdm_s_subsample(s_ap, s_ap.xps.b <= 0.11e9, wp, opt);

            % Prepare powder average and merge (average all)
            s_pa_b0.xps.a_ind = s_pa_b0.xps.b >= 0;
            s_ap_b0.xps.a_ind = s_ap_b0.xps.b >= 0;

            s_pa_b0.xps = msf_rmfield(s_pa_b0.xps, 's_ind');
            s_ap_b0.xps = msf_rmfield(s_ap_b0.xps, 's_ind');

            % Powder average and merge
            s_pa_b0 = mdm_s_powder_average(s_pa_b0, wp, opt);
            s_ap_b0 = mdm_s_powder_average(s_ap_b0, wp, opt);
            s = mdm_s_merge({s_pa_b0, s_ap_b0}, wp, 'topup', opt);

            % Copy file
            copyfile(s.nii_fn, output.topup_nii_fn);
            mdm_xps_save(s.xps, output.topup_xps_fn);

            % Write topup specification file
            % File is OK with both pa/ap and ap/pa order
            % and define topup data path
            %
            % xxx: this should find correct information from a json file
            mdm_txt_write({'0 1 0 0.1', '0 -1 0 0.1'}, ...
                output.topup_spec_fn, opt);



        end
    end
end
