classdef dp_node_dmri_topup_apply < dp_node

    % apply topup to volume
    %
    % assume we do not have full ap/pa data, but only in ap

    methods
        
        % construct names of output files
        function output = i2o(obj, input)

            output.op = input.op;

            output.nii_fn = msf_fn_new_path(output.op, ...
                msf_fn_append(input.nii_ap_fn, '_topup'));
            
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
        end

        function output = execute(obj, input, output)

            % connect to data
            s_ap = mdm_s_from_nii(input.nii_ap_fn);
            s_pa = mdm_s_from_nii(input.nii_pa_fn);

            % we may need to build a volume of zeros, if 
            % we did not acquire all data both directions
            if (s_ap.xps.n ~= s_pa.xps.n)

                % assert that pa is the one with few directions
                assert(s_pa.xps.n < s_ap.xps.n, 'assumption invalid');

                [I,h] = mdm_nii_read(s_ap.nii_fn);
                tmp_nii_fn = fullfile(wp, 'DMRI_PA_zeros.nii.gz');
                mdm_nii_write(zeros(size(I)), tmp_nii_fn, h);
                s_tmp_pa = s_ap;
                s_tmp_pa.nii_fn = tmp_nii_fn;
            else
                s_tmp_pa = s_ap;
            end

            % Define command
            cmd = sprintf(['bash --login -c ''applytopup ' ...
                '--imain="%s","%s" ' ...
                '--inindex=1,2 ' ...
                '--topup="%s" ' ...
                '--datain="%s" ' ...
                '--out="%s"', ...
                ''''], ...
                s_tmp_pa.nii_fn, ...    % imain_1
                s_ap.nii_fn, ...        % imain_2
                input.topup_data_path, ...    % topup
                input.topup_spec_fn, ...      % spec
                output.nii_fn);         % output_fn
            
            system(cmd);

            % save the xps too
            mdm_xps_save(s_ap.xps, output.xps_fn);

        end
    end
end

