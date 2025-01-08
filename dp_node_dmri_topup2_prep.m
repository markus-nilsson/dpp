classdef dp_node_dmri_topup2_prep < dp_node

    % pulls out data and saves it in ap pa order

    methods

        function output = i2o(~, input)

            % Pass on input to next node
            output = input;

            output.topup_nii_fn  = fullfile(output.op, 'topupinput.nii.gz');
            output.topup_spec_fn = fullfile(output.op, 'topup.txt');
            output.topup_xps_fn  = mdm_xps_fn_from_nii_fn(output.topup_nii_fn);

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
            
        end

        function output = execute(~, input, output)

            % define options
            opt = mdm_opt();

            % connect to data
            s_ap = mdm_s_from_nii(input.ap_dmri_fn);
            s_pa = mdm_s_from_nii(input.pa_dmri_fn);

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

            % Make sure only relevant fields are left
            f = @(x) struct('b', x.b, 'n', x.n);
            s_ap_b0.xps = f(s_ap_b0.xps);
            s_pa_b0.xps = f(s_pa_b0.xps);

            % Merge
            s = mdm_s_merge({s_ap_b0, s_pa_b0}, wp, 'topup', opt);

            % Copy file
            copyfile(s.nii_fn, output.topup_nii_fn);
            mdm_xps_save(s.xps, output.topup_xps_fn);

            % Write topup specification file, with info from json
            ap_json = jsondecode(cell2mat(mdm_txt_read(input.ap_json_fn)));
            pa_json = jsondecode(cell2mat(mdm_txt_read(input.pa_json_fn)));

            % Test conditions
            if (~strcmp(ap_json.Manufacturer, 'Siemens'))
                error('Not Siemens data, code not validated');
            end

            if (~strcmp(ap_json.PhaseEncodingDirection, 'j-'))
                error('Unexpected ap encoding direction');
            end

            if (~strcmp(pa_json.PhaseEncodingDirection, 'j'))
                error('Unexpected pa encoding direction');
            end

            ap_ro_time = ap_json.TotalReadoutTime;
            pa_ro_time = ap_json.TotalReadoutTime;

            % Save to file
            tmp = {...
                sprintf('0 1 0 %1.5f', ap_ro_time), ...
                sprintf('0 -1 0 %1.5f', pa_ro_time)};
            mdm_txt_write(tmp, output.topup_spec_fn, opt);

        end
    end
end

