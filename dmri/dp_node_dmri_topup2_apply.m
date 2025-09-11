classdef dp_node_dmri_topup2_apply < dp_node

    % Applies TOPUP distortion correction using the enhanced version 2 implementation.
    % Corrects susceptibility-induced distortions in diffusion data using computed field maps.

    methods
        
        % construct names of output files
        function output = i2o(obj, input)

            output.op = input.op;

            output.dmri_fn = dp.new_fn(output.op, input.ap_dmri_fn, '_topup');            
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.dmri_fn);

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;
        end

        function output = execute(obj, input, output)

            % connect to data
            s_ap = mdm_s_from_nii(input.ap_dmri_fn);
            s_pa = mdm_s_from_nii(input.pa_dmri_fn);

            % we may need to build a volume of zeros, if 
            % we did not acquire all data both directions
            if (s_ap.xps.n ~= s_pa.xps.n)

                % assert that pa is the one with few directions
                assert(s_pa.xps.n < s_ap.xps.n, 'assumption invalid');

                [I,h] = mdm_nii_read(s_ap.nii_fn);
                tmp_nii_fn = fullfile(output.tmp.bp, 'DMRI_PA_zeros.nii.gz');
                mdm_nii_write(zeros(size(I)), tmp_nii_fn, h);
                s_tmp_pa = s_ap;
                s_tmp_pa.nii_fn = tmp_nii_fn;

            else
                s_tmp_pa = s_pa;
            end

            % Define command
            msf_mkdir(fileparts(output.dmri_fn));

            cmd = sprintf(['bash --login -c ''applytopup ' ...
                '--imain="%s","%s" ' ...
                '--inindex=1,2 ' ...
                '--topup="%s" ' ...
                '--datain="%s" ' ...
                '--out="%s"', ...
                ''''], ...
                s_ap.nii_fn, ...        % imain_1 (acquired data first)
                s_tmp_pa.nii_fn, ...    % imain_2
                input.topup_data_path, ...    % topup
                input.topup_spec_fn, ...      % spec
                output.dmri_fn);         % output_fn
            
            system(cmd);

            % save the xps too
            mdm_xps_save(s_ap.xps, output.xps_fn);

        end
    end
end

