classdef p3_topup < dp_node

    methods

        function obj = p3_topup()
            obj.previous_node = {p1_merge, p2_denoise};
        end

        % output holds the output from previous steps
        function input = po2i(obj, output)
            input.bp = output.denoise_bp;
            input.nii_ap_fn = output.denoise_nii_fn;
            input.nii_pa_fn = output.merge_fwf_pa_fn;
        end

        % construct names of output files
        function output = i2o(obj, input)

            output.bp = input.bp;

            op = fullfile(input.bp, input.id);

            [~, name, ext] = msf_fileparts(input.nii_ap_fn);

            % here, override name
            name = 'FWF_dn';

            output.nii_fn = fullfile(op, [name '_topup' ext]);
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);

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

            % define temporary working path
            wp = output.tmp.bp;


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

            % Write topup specification file
            % File is OK with both pa/ap and ap/pa order
            % and define topup data path
            topup_spec_fn = mdm_txt_write({'0 -1 0 1', '0 1 0 1'}, ...
                fullfile(wp, 'topup.txt'), opt);
            topup_data_path = fullfile(wp, 'topup_data');

            % run topup
            fsl_topup(s.nii_fn, topup_spec_fn, topup_data_path, opt);

            % apply to full volume (prep needed first; make a volume with zeros, as
            % we did not acquire all data in ap pa dirs)

            [I,h] = mdm_nii_read(s_ap.nii_fn);
            tmp_nii_fn = fullfile(wp, 'FWF_PA_zeros.nii.gz');
            mdm_nii_write(zeros(size(I)), tmp_nii_fn, h);
            s_tmp_pa = s_ap;
            s_tmp_pa.nii_fn = tmp_nii_fn;

            fsl_applytopup(s_tmp_pa.nii_fn, s_ap.nii_fn, topup_data_path, topup_spec_fn, ...
                output.nii_fn, opt);

            % save the xps too
            mdm_xps_save(s_ap.xps, output.xps_fn);


        end
    end
end

