classdef p5_coreg < dp_node

    methods

        function obj = p5_coreg()
            bp = '/media/fuji/MyBook1/BOF130_APTw/data/seg';
            obj.previous_node = {p0_list_subjects(bp), p4_mc};
        end

        function input = po2i(obj, previous_output)
            input.nii_fn = previous_output.mc_nii_fn;

            input.seg_bp = previous_output.list_subjects_bp;

            input.opt = mdm_opt(previous_output.opt);
            input.opt.do_overwrite = 1;

            input.elastix_p = elastix_p_6dof(1000);
            input.elastix_p.AutomaticTransformInitialization = 'true';

            % use the T1 as our registration target
            seg_op = fullfile(previous_output.list_subjects_bp, previous_output.id);
            input.ref_fn = fullfile(seg_op, 'raw_bet', 't1_bet_raw.nii.gz');

        end

        function output = i2o(obj, input)

            % output will here be placed in the seg folder
            output.bp = fullfile(input.seg_bp);

            % names of output files
            op = fullfile(output.bp, input.id, 'dmri');

            [~, name, ext] = msf_fileparts(input.nii_fn);

            output.op = op; % motion correction needs this
            output.nii_fn = fullfile(op, [name '_coreg' ext]);
            output.xps_fn = mdm_xps_fn_from_nii_fn(output.nii_fn);


            % add a temporary path
            output.tmp.bp = msf_tmp_path();
            output.tmp.nii_fn = fullfile(output.tmp.bp, 'FWF_tmp.nii.gz');
            output.tmp.do_delete = 1;
            output.tmp.elastix_p_fn = fullfile(output.tmp.bp, 'p_coreg.txt');

        end

        function output = execute(obj, input, output)

            % diffusion data
            s_fwf = mdm_s_from_nii(input.nii_fn);

            % subsample high b-value data to drive registration
            ind = (s_fwf.xps.b > 1.7e9) & (s_fwf.xps.b_delta > 0.9);
            [I,h] = mdm_nii_read(s_fwf.nii_fn);
            I = mean(I(:,:,:,ind), 4);
            mdm_nii_write(I, output.tmp.nii_fn, h);

            % coregister
            elastix_p_write(input.elastix_p, output.tmp.elastix_p_fn);

            opt.mio.coreg.clear_header = 0;
            [tmp_fn, tpm_fn, T]  = mdm_coreg(output.tmp.nii_fn, ...
                input.ref_fn, output.tmp.elastix_p_fn, output.tmp.bp, opt);

            % apply transform to all diffusion data
            [I,h] = mdm_nii_read(s_fwf.nii_fn);
            I = mio_transform(I, T.t, h, opt);
            h = mdm_nii_read_header(input.ref_fn); % write the header of the target
            mdm_nii_write(I, output.nii_fn, h);
            mdm_xps_save(s_fwf.xps, output.xps_fn);

            % warning: no rotation of directions currently!

        end
    end
end