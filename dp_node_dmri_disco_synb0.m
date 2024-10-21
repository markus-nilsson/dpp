classdef dp_node_dmri_disco_synb0 < dp_node

    properties
        license_fn = '~/freesurfer_license.txt';
    end

    methods

        % construct names of output files
        function output = i2o(obj, input)

            output = input;

            % Main disco output for us
            output.synb0_fn = fullfile(output.op, 'synb0.nii.gz');

            % Topup-specific files
            output.topup_nii_fn = fullfile(output.op, 'topupsyninput.nii.gz');            
            output.topup_xps_fn = mdm_xps_fn_from_nii_fn(output.topup_nii_fn);            
            output.topup_spec_fn = fullfile(output.op, 'topup.txt');            

            % Prepare for apply topup
            output.nii_ap_fn = input.dmri_fn;
            output.nii_pa_fn = output.synb0_fn;

            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;

        end

        function output = execute(obj, input, output)

            % define and prepare paths
            wp = output.tmp.bp;
            op = fullfile(output.tmp.bp, 'OUTPUT');
            msf_mkdir(op);

            % pull out the b0
            [I,h] = mdm_nii_read(input.dmri_fn);
            xps = mdm_xps_load(mdm_xps_fn_from_nii_fn(input.dmri_fn));

            ind = find(xps.b == min(xps.b), 1, 'first') == (1:xps.n);
            I = I(:,:,:,ind);
            I(I < 0) = 0; 
            xps = mdm_xps_subsample(xps, ind);

            mdm_nii_write(double(I), fullfile(wp, 'b0.nii.gz'), h);

            % copy the t1
            copyfile(input.t1_fn, fullfile(wp, 'T1.nii.gz'));

            % run the docker container
            cmd = sprintf('docker run --rm -v %s:/INPUTS/ -v %s:/OUTPUTS/ -v %s:/extra/freesurfer/license.txt --user $(id -u):$(id -g) leonyichencai/synb0-disco:v3.1 -notopup', ...
                [wp '/'], [op '/'], obj.license_fn);

            [r, msg, cmd_full] = msf_system(cmd);

            % save the synthetic b0
            msf_mkdir(input.op);
            copyfile(fullfile(op, 'b0_u.nii.gz'), output.synb0_fn);


            % Prepare for topup
            J = mdm_nii_read(output.synb0_fn);

            mdm_nii_write(cat(4, I, J), output.topup_nii_fn, h);

            xps2 = mdm_xps_from_bt(cat(1, xps.bt, [0 0 0 0 0 0]));

            mdm_xps_save(xps2, output.topup_xps_fn);
           
            % Write an acqparam file
            %
            % xxx: get proper value from json
            txt = {'0 1 0 0.062', '0 1 0 0.000'};
            mdm_txt_write(txt, output.topup_spec_fn);
            

        end

    end
end








