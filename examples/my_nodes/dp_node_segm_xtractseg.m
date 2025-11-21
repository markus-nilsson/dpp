classdef dp_node_segm_xtractseg < dp_node_segm

    % inputs
    % dmri_fn
    % bval_fn
    % bvec_fn
    % mask_fn

    % to do: flow management, e.g. deleting files and more

    methods

        function obj = dp_node_segm_xtractseg()
            obj.output_test = {'labels_fn'};
        end

        function output = i2o(obj, input)

            output.op = input.op;

            f = @(x) fullfile(output.op, x);
            % output.mask_fn = f('nodif_brain_mask.nii.gz');
            % output.dmri_fn = f('dmri.nii.gz');
            % output.bval_fn = f('x.bvals');
            % output.bvec_fn = f('x.bvecs');

            output.mask_fn = f('nodif_brain_mask_MNI.nii.gz');
            output.dmri_fn = f('Diffusion_MNI.nii.gz');
            output.fa_fn = f('FA_MNI.nii.gz');
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
            copyfile(input.dmri_fn, fullfile(output.op, 'dmri.nii.gz'));
            copyfile(input.bval_fn, output.bval_fn);
            copyfile(input.bvec_fn, output.bvec_fn);

            % Preliminary implementation
            if (~isempty(input.mask_fn))
                copyfile(input.mask_fn, output.mask_fn);
            end


            % convert relative to absolute path
            [~,tmp] = fileattrib(output.op);
            op = tmp.Name;

            % cmd = sprintf(...
            %     'docker run -v "%s":/data -t "%s" TractSeg -i "%s" -o /data %s --bvals "%s" --bvecs "%s" %s', ...
            %     op, ...
            %     'wasserth/tractseg_container:master', ... % docker name
            %     'data/dmri.nii.gz', ...
            %     '--raw_diffusion_input', ... % options
            %     'data/x.bvals', ...
            %     'data/x.bvecs', ...
            %     '--preprocess'); % register to mni space

            cmd = sprintf(...
                'docker run -v "%s":/data -t "%s" TractSeg -i "%s" -o /data %s --bvals "%s" --bvecs "%s" %s', ...
                op, ...
                'wasserth/tractseg_container:master', ...
                'data/dmri.nii.gz', ...
                '--raw_diffusion_input', ...
                'data/x.bvals', ...
                'data/x.bvecs', ...
                '--preprocess --tract_definition xtract');


            obj.syscmd(cmd);


            % wrap up the files in a 4D volume
            h = mdm_nii_read_header(output.dmri_fn);
            labels = obj.segm_labels();
            R = zeros(h.dim(2), h.dim(3), h.dim(4), numel(labels));
            for c = 1:numel(labels)
                tmp = mdm_nii_read(fullfile(output.op, ...
                    'bundle_segmentations_MNI', ...
                    cat(2, labels{c}, '.nii.gz')));
                R(:,:,:,c) = tmp;
            end
            mdm_nii_write(uint8(R), output.labels_fn, h);

        end

    end

    methods (Hidden)

        function [labels, ids] = segm_info(obj)

            % dp_node_segm_xtractseg.segm_info()  — XTRACT bundle names

            txt = { ...
                '0: ac', ...        % Anterior commissure
                '1: af_l', ...      % Arcuate fasciculus (left)
                '2: af_r', ...      % Arcuate fasciculus (right)
                '3: ar_l', ...      % Acoustic radiation (left)
                '4: ar_r', ...      % Acoustic radiation (right)
                '5: atr_l', ...     % Anterior thalamic radiation (left)
                '6: atr_r', ...     % Anterior thalamic radiation (right)
                '7: cbd_l', ...     % Cingulum bundle – dorsal (left)
                '8: cbd_r', ...     % Cingulum bundle – dorsal (right)
                '9: cbp_l', ...     % Cingulum bundle – perigenual (left)
                '10: cbp_r', ...    % Cingulum bundle – perigenual (right)
                '11: cbt_l', ...    % Cingulum bundle – temporal (left)
                '12: cbt_r', ...    % Cingulum bundle – temporal (right)
                '13: cst_l', ...    % Corticospinal tract (left)
                '14: cst_r', ...    % Corticospinal tract (right)
                '15: fa_l', ...     % Frontal aslant tract (left)
                '16: fa_r', ...     % Frontal aslant tract (right)
                '17: fma', ...      % Forceps major (splenium of corpus callosum)
                '18: fmi', ...      % Forceps minor (genu of corpus callosum)
                '19: fx_l', ...     % Fornix (left)
                '20: fx_r', ...     % Fornix (right)
                '21: ifo_l', ...    % Inferior fronto-occipital fasciculus (left)
                '22: ifo_r', ...    % Inferior fronto-occipital fasciculus (right)
                '23: ilf_l', ...    % Inferior longitudinal fasciculus (left)
                '24: ilf_r', ...    % Inferior longitudinal fasciculus (right)
                '25: mcp', ...      % Middle cerebellar peduncle
                '26: mdlf_l', ...   % Middle longitudinal fasciculus (left)
                '27: mdlf_r', ...   % Middle longitudinal fasciculus (right)
                '28: or_l', ...     % Optic radiation (left)
                '29: or_r', ...     % Optic radiation (right)
                '30: slf1_l', ...   % Superior longitudinal fasciculus I (left)
                '31: slf1_r', ...   % Superior longitudinal fasciculus I (right)
                '32: slf2_l', ...   % Superior longitudinal fasciculus II (left)
                '33: slf2_r', ...   % Superior longitudinal fasciculus II (right)
                '34: slf3_l', ...   % Superior longitudinal fasciculus III (left)
                '35: slf3_r', ...   % Superior longitudinal fasciculus III (right)
                '36: str_l', ...    % Superior thalamic radiation (left)
                '37: str_r', ...    % Superior thalamic radiation (right)
                '38: uf_l', ...     % Uncinate fasciculus (left)
                '39: uf_r', ...     % Uncinate fasciculus (right)
                '40: vof_l', ...    % Vertical occipital fasciculus (left)
                '41: vof_r' ...     % Vertical occipital fasciculus (right)
                };


            a = @(x) strsplit(x, ' ');
            b = @(x,i) x{i};
            c = @(x) 1 + str2num(x(1:(end-1)));

            labels = cellfun(@(x) b(a(x),2), txt, 'UniformOutput', false);
            ids = cellfun(@(x) c(b(a(x),1)), txt, 'UniformOutput', false);


        end
    end
end

