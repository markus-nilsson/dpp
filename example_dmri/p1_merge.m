classdef p1_merge < dp_node

    methods

        function obj = p1_merge()
            obj.previous_node = p0_list_subjects;
        end

        function input = po2i(obj, output) % build input to this step from previous output

            % See p0 for definitions
            ip = fullfile(output.bp, output.id);

            % Find the STE
            d = dir(fullfile(ip, '*STE_v*.nii.gz'));

            % Deal with exceptions
            if (contains(ip, 'BoF130_APTw_106/20180313_2'))
                d = d(2:3); % first STE is bad
            end

            if (numel(d) ~= 2)
                error('Missing STEs');
            end

            % Find the LTE
            d2 = dir(fullfile(ip, '*LTE_v*.nii.gz'));

            if (numel(d2) ~= 1)
                error('Did not find LTE');
            end

            input.nii_ap_fn = fullfile(ip, d(1).name);
            input.nii_pa_fn = fullfile(ip, d(2).name);
            input.nii_lte_fn = fullfile(ip, d2.name);

        end

        function output = i2o(obj, input)

            output.id = input.id;
            output.bp = '/media/fuji/MyBook1/BOF130_APTw/data/dmri';

            op = fullfile(output.bp, output.id);

            output.fwf_ap_fn = fullfile(op, 'FWF_ap.nii.gz');
            output.fwf_pa_fn = fullfile(op, 'FWF_pa.nii.gz');

        end


        function outputs = execute(obj, inputs, outputs)

            % this setting need to be driven from somewhere
            opt.do_overwrite = 0;


            % connect to data
            s_pa = mdm_s_from_nii(inputs.nii_pa_fn, 0); % this is the reversed one
            s_ap = mdm_s_from_nii(inputs.nii_ap_fn, 0);

            s_lte = mdm_s_from_nii(inputs.nii_lte_fn, 1);

            % merge LTE and STE data
            s_fwf = mdm_s_merge({s_lte, s_ap}, ...
                fileparts(outputs.fwf_ap_fn), 'FWF_ap', opt);

            % Convert data to double (for denoising to work)
            [I,h] = mdm_nii_read(s_fwf.nii_fn);
            mdm_nii_write(double(I), s_fwf.nii_fn, h);


            % copy the PA data and convert it to double (use merge here, sloppy code)
            s_fwf_pa = mdm_s_merge({s_pa}, fileparts(outputs.fwf_pa_fn), 'FWF_pa', opt);

            [I,h] = mdm_nii_read(s_fwf_pa.nii_fn);
            mdm_nii_write(double(I), s_fwf_pa.nii_fn, h);


        end

    end

end




