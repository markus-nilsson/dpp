classdef dp_node_segm_tractseg < dp_node

    % inputs
    % dmri_fn
    % bval_fn
    % bvec_fn
    % mask_fn

    % to do: flow management, e.g. deleting files and more

    methods

        function obj = dp_node_segm_tractseg()
            obj.output_test = {'labels_fn'};
        end

        function output = i2o(obj, input)

            output.op = fullfile(input.op, 'tractseg');

            f = @(x) fullfile(output.op, x);
            output.mask_fn = f('nodif_brain_mask.nii.gz');
            output.dmri_fn = f('dmri.nii.gz');
            output.bval_fn = f('x.bvals');
            output.bvec_fn = f('x.bvecs');

            output.labels_fn = f('bundles.nii.gz');

            output.tmp.bp = msf_tmp_path();
            output.tmp.do_delete = 1;

        end

        function output = execute(obj, input, output)

            % prepare
            msf_mkdir(output.op);

            % put brain mask and dmri into the right place
            copyfile(input.dmri_fn, output.dmri_fn);
            copyfile(input.bval_fn, output.bval_fn);
            copyfile(input.bvec_fn, output.bvec_fn);

            % Preliminary implementation
            if (~isempty(input.mask_fn))
                copyfile(input.mask_fn, output.mask_fn);
            end
            

            % convert relative to absolute path
            [~,tmp] = fileattrib(output.op);
            op = tmp.Name;

            cmd = sprintf(...
                'docker run -v %s:/data -t %s TractSeg -i %s -o /data %s --bvals %s --bvecs %s %s', ...
                op, ...
                'wasserth/tractseg_container:master', ... % docker name
                'data/dmri.nii.gz', ...
                '--raw_diffusion_input', ... % options
                'data/x.bvals', ...
                'data/x.bvecs', ...
                '--preprocess'); % register to mni space

            [s,r] = system(cmd);

            if (s ~= 0) % output the command if this failed
                obj.log(1, cmd);
                obj.log(1, '');
                obj.log(1, r);
                obj.log(1, '');
            end
           
            % wrap up the files in a 4D volume
            h = mdm_nii_read_header(input.dmri_fn);
            labels = obj.segm_labels();
            R = zeros(h.dim(2), h.dim(3), h.dim(4), numel(labels));
            for c = 1:numel(labels)
                tmp = mdm_nii_read(fullfile(output.op, ...
                    'bundle_segmentations', ...
                    cat(2, labels{c}, '.nii.gz')));
                R(:,:,:,c) = tmp;
            end
            mdm_nii_write(uint8(R), output.labels_fn, h);

        end

        function ids = segm_ids(obj)
            [~,ids] = obj.segm_info();
            ids = cell2mat(ids);
        end

        function labels = segm_labels(obj)
            labels = obj.segm_info();
        end
    end

    methods (Hidden)

        function [labels, ids] = segm_info(obj)

            txt = {...
                '0: AF_left         (Arcuate fascicle)', ...
                '1: AF_right', ...
                '2: ATR_left        (Anterior Thalamic Radiation)', ...
                '3: ATR_right', ...
                '4: CA              (Commissure Anterior)', ...
                '5: CC_1            (Rostrum)', ...
                '6: CC_2            (Genu)', ...
                '7: CC_3            (Rostral body (Premotor))', ...
                '8: CC_4            (Anterior midbody (Primary Motor))', ...
                '9: CC_5            (Posterior midbody (Primary Somatosensory))', ...
                '10: CC_6           (Isthmus)', ...
                '11: CC_7           (Splenium)', ...
                '12: CG_left        (Cingulum left)', ...
                '13: CG_right', ...
                '14: CST_left       (Corticospinal tract)', ...
                '15: CST_right', ...
                '16: MLF_left       (Middle longitudinal fascicle)', ...
                '17: MLF_right', ...
                '18: FPT_left       (Fronto-pontine tract)', ...
                '19: FPT_right', ...
                '20: FX_left        (Fornix)', ...
                '21: FX_right', ...
                '22: ICP_left       (Inferior cerebellar peduncle)', ...
                '23: ICP_right', ...
                '24: IFO_left       (Inferior occipito-frontal fascicle)', ...
                '25: IFO_right', ...
                '26: ILF_left       (Inferior longitudinal fascicle)', ...
                '27: ILF_right', ...
                '28: MCP            (Middle cerebellar peduncle)', ...
                '29: OR_left        (Optic radiation)', ...
                '30: OR_right', ...
                '31: POPT_left      (Parieto‐occipital pontine)', ...
                '32: POPT_right', ...
                '33: SCP_left       (Superior cerebellar peduncle)', ...
                '34: SCP_right', ...
                '35: SLF_I_left     (Superior longitudinal fascicle I)', ...
                '36: SLF_I_right', ...
                '37: SLF_II_left    (Superior longitudinal fascicle II)', ...
                '38: SLF_II_right', ...
                '39: SLF_III_left   (Superior longitudinal fascicle III)', ...
                '40: SLF_III_right', ...
                '41: STR_left       (Superior Thalamic Radiation)', ...
                '42: STR_right', ...
                '43: UF_left        (Uncinate fascicle)', ...
                '44: UF_right', ...
                '45: CC             (Corpus Callosum - all)', ...
                '46: T_PREF_left    (Thalamo-prefrontal)', ...
                '47: T_PREF_right', ...
                '48: T_PREM_left    (Thalamo-premotor)', ...
                '49: T_PREM_right', ...
                '50: T_PREC_left    (Thalamo-precentral)', ...
                '51: T_PREC_right', ...
                '52: T_POSTC_left   (Thalamo-postcentral)', ...
                '53: T_POSTC_right', ...
                '54: T_PAR_left     (Thalamo-parietal)', ...
                '55: T_PAR_right', ...
                '56: T_OCC_left     (Thalamo-occipital)', ...
                '57: T_OCC_right', ...
                '58: ST_FO_left     (Striato-fronto-orbital)', ...
                '59: ST_FO_right', ...
                '60: ST_PREF_left   (Striato-prefrontal)', ...
                '61: ST_PREF_right', ...
                '62: ST_PREM_left   (Striato-premotor)', ...
                '63: ST_PREM_right', ...
                '64: ST_PREC_left   (Striato-precentral)', ...
                '65: ST_PREC_right', ...
                '66: ST_POSTC_left  (Striato-postcentral)', ...
                '67: ST_POSTC_right', ...
                '68: ST_PAR_left    (Striato-parietal)', ...
                '69: ST_PAR_right', ...
                '70: ST_OCC_left    (Striato-occipital)', ...
                '71: ST_OCC_right'};

            a = @(x) strsplit(x, ' ');
            b = @(x,i) x{i};
            c = @(x) 1 + str2num(x(1:(end-1)));

            labels = cellfun(@(x) b(a(x),2), txt, 'UniformOutput', false);
            ids = cellfun(@(x) c(b(a(x),1)), txt, 'UniformOutput', false);


        end
    end
end

