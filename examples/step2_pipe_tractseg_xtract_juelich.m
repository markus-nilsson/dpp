% Root to NIfTI data
base_path = '/path/to/your/data/nii';

% Subjects → add dmri/xps/op
id1 = my_primary_node(base_path, '*');
% id1 = dp_node_io_filter_by_number(1).connect(id1);  % keep only first n subjects

id2 = dp_node_io_append({...
  {'dmri_fn', @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc.nii.gz')}, ...
  {'xps_fn',  @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc_xps.mat')}, ...
  {'op',      @(x) fullfile(x.bp, x.id, 'tractseg')}}).connect(id1);

% b0 → mask
m0 = dp_node_dmri_subsample_b0().connect(id2);
m1 = dp_node_segm_hd_bet().connect(m0, 'm1');

% xps→bval/bvec, gradcheck
t0 = dp_node_dmri_io_xps_to_bval_bvec().connect(id2, 't0');
t1 = dp_node_mrtrix_dwigradcheck().connect(t0);

% merge mask + grads, alias mask
t2 = dp_node_io_merge({t1, m1}); t2.do_prefix = 0;
t3 = dp_node_io('mask_fn', 'm1_mask_fn').connect(t2);

% TractSeg (MNI outputs: Diffusion_MNI, FA_MNI, nodif_brain_mask_MNI, bundles.nii.gz)
t4 = dp_node_segm_tractseg().connect(t3);

% XTRACT definitions in a separate output folder
xt_op = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg_xtract')).connect(t3);
xt1 = dp_node_segm_xtractseg().connect(xt_op);

% xt1.run('report');
% xt1.run('execute');
% xt1.run('execute', struct('do_overwrite',1));

% DTI (LLS) on TractSeg’s MNI-space diffusion data (b_delta = 1) into subfolder <op>/dti_lls
dti1 = dp_node_dmri_xps_from_bval_bvec(1).connect(t4);
dti2 = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg', 'dti_lls')).connect(dti1);
dti3 = dp_node_dmri_dti().connect(dti2);

% Refine brain mask and trim FA/MD/AD/RD/S0 maps using smoothing + median filtering
dti_trim = my_mask_trim().connect(dti3);


% Register AD/RD output filenames for dti_lls (not used downstream in this script)
% dti3_append = dp_node_io_append({
%   {'ad_fn', @(x) fullfile(x.op, 'dti_lls_ad.nii.gz')}, ...
%   {'rd_fn', @(x) fullfile(x.op, 'dti_lls_rd.nii.gz')}
% }).connect(dti3);


% Merge trimmed DTI maps with TractSeg outputs (keep original field names)
mdt = dp_node_io_merge({dti_trim, t4}); mdt.do_prefix = 0;

% Expose only labels + FA/MD/AD/RD for TractSeg ROI stats (used by t5, t5_split)
troi = dp_node_io_rename({
  {'labels_fn','dp_node_segm_tractseg_labels_fn'}, ...
  {'fa_fn','fa_fn'}, ...
  {'md_fn','md_fn'}, ...
  {'ad_fn','ad_fn'}, ...
  {'rd_fn','rd_fn'} ...
}).connect(mdt);

% Merge trimmed DTI maps with XTRACT-based TractSeg outputs (keep original field names)
mdtx = dp_node_io_merge({dti_trim, xt1}); mdtx.do_prefix = 0;

% Expose only labels + FA/MD/AD/RD for XTRACT ROI stats (used by xt2, xt1_split)
xtroi = dp_node_io_rename({
  {'labels_fn','dp_node_segm_xtractseg_labels_fn'}, ...
  {'fa_fn','fa_fn'}, ...
  {'md_fn','md_fn'}, ...
  {'ad_fn','ad_fn'}, ...
  {'rd_fn','rd_fn'} ...
}).connect(mdtx);


% TractSeg bundle ROI stats → CSV (mean + voxel count)
t5 = dp_node_roi_from_label('tractseg', t4).connect(troi);
t_csv = dp_node_csv('tractseg_export','../report/csv', {'mean','n'}).connect(t5);

% TractSeg: split selected bundles into 3 z-slabs (I/II/III) and export ROI stats
ts_split_list = { ...
    'CST_left','CST_right', ...
    'SCP_left','SCP_right', ...
    'ICP_left','ICP_right', ...
    'CC_1','CC_2','CC_3','CC_4','CC_5','CC_6','CC_7', ...
    'MCP', ...
    'IFO_left','IFO_right', ...
    'ILF_left','ILF_right', ...
    'CG_left','CG_right', ...
    'UF_left','UF_right'};

% TractSeg: split selected bundles into 3 z-slabs (I/II/III) and export ROI stats → CSV (mean + voxel count)
t5_split  = split_rois('tractseg_slab', t4, ts_split_list).connect(troi);
t6_split  = dp_node_csv('tractseg_export_with_slabs','../report/csv', {'mean','n'}).connect(t5_split);

% XTRACT-based TractSeg bundle ROI stats → CSV (mean + voxel count)
xt2 = dp_node_roi_from_label('tractseg_xtract', xt1).connect(xtroi);
xt3 = dp_node_csv('tractseg_xtract_export','../report/csv', {'mean','n'}).connect(xt2);

% XTRACT: split CST (left/right) into 3 z-slabs and export ROI stats → CSV (mean + voxel count)
xt1_split = split_rois('tractseg_xtract_slab', xt1, {'cst_l','cst_r'}).connect(xtroi);
xt_csv = dp_node_csv('tractseg_xtract_export_with_slabs','../report/csv', {'mean','n'}).connect(xt1_split);


% ------------- JHU ROIs using ANTs (quick registration) ----------------------
%
% TractSeg places dMRI in a semi-MNI rigid space (t4.*_MNI).
% DTI maps (dti3) are computed on that same grid.
% To align the JHU atlas with this subject grid:
%   (A) Register subject FA (semi-MNI) → JHU FA template using ANTs quick mode
%   (B) Apply the inverse warp to bring JHU labels → subject trimmed FA grid
%   (C) Crop warped labels by the subject mask
%
% Result: JHU atlas labels and trimmed DTI maps are voxel-aligned on the semi-MNI (TractSeg) grid.


% JHU atlas paths
jhu_fa_fn     = '/usr/local/fsl/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz';
jhu_labels_fn = '/usr/local/fsl/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz';

% ----------- ANTs quick registration branch --------
amni0 = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg_jhu_ants_quick')).connect(dti_trim);
% amni0.run('report');

% ANTs: subject trimmed FA (moving) -> JHU FA (fixed) 
amni1 = dp_node_io('nii_fn', 'fa_fn').connect(amni0); % moving: trimmed FA
% amni1.run('report');

amni2 = dp_node_io('target_fn', @(x) jhu_fa_fn).connect(amni1); % fixed: JHU FA
% amni2.run('report');

amni3 = dp_node_ants_reg_quick().connect(amni2);   
% amni3.run('report');

% Attach trimmed FA grid as reference for antsApply
amni4 = dp_node_io_merge({amni3, dti_trim}); 
amni4.do_prefix = 0;

% Use trimmed FA as ref_fn
amni5 = dp_node_io_append({{'ref_fn','my_mask_trim_fa_fn'}}).connect(amni4);

% Warp full JHU labels to subject trimmed FA space (using inverse chain)
amni6 = dp_node_io('nii_fn', @(x) jhu_labels_fn).connect(amni5);
amni7 = dp_node_ants_apply(' -n NearestNeighbor').connect(amni6);
% amni7.nii_fn: JHU labels (quick) on trimmed FA grid

% Crop warped labels by subject mask on same grid 
amni_merge1  = dp_node_io_merge({amni7, dti_trim}); amni_merge1.do_prefix = 0;
amni_merge2 = dp_node_io_append({{'mask_fn','my_mask_trim_fa_fn'}}).connect(amni_merge1);
jhu_crop = dp_node_atlas_crop_to_mask().connect(amni_merge2);


% QC
if (0)
    qc1 = dp_node_io_merge({dti_trim, amni3, jhu_crop}); qc1.do_prefix = 0;

    % subject trimmed FA + labels warped back from MNI to subject space
    if (0)
        qc2 = dp_node_io_rename({
            {'fa_fn',     'fa_fn'}, ...
            {'labels_fn', 'dp_node_atlas_crop_to_mask_nii_fn'}, ...
            {'mask_fn',   'mask_fn'}
            }).connect(qc1);
    end

    % subject FA warped into JHU (MNI) space + labels in MNI
    if (0)
        qc2 = dp_node_io_rename({
            {'fa_fn',     'dp_node_ants_reg_quick_warped_fn'}, ...
            {'labels_fn', @(x) jhu_labels_fn}
            }).connect(qc1);
    end

    % JHU template FA + JHU atlas labels (reference anatomy in MNI space)
    if (0)
        qc2 = dp_node_io_rename({
            {'fa_fn',     @(x) jhu_fa_fn}, ...
            {'labels_fn', @(x) jhu_labels_fn}
            }).connect(qc1);
    end

    % qc2.run('mgui');

    qc3 = dp_node_roi_from_label('tmp', dp_node_segm_jhu()).connect(qc2);
    qc3.run('mgui');
end


% ****** Merge for ROI stats ******

mda = dp_node_io_merge({dti_trim, jhu_crop});
mda.do_prefix = 0;

aroi = dp_node_io_rename({
  {'labels_fn','dp_node_atlas_crop_to_mask_nii_fn'}, ...
  {'fa_fn','fa_fn'}, ...
  {'md_fn','md_fn'}, ...
  {'ad_fn','ad_fn'}, ...
  {'rd_fn','rd_fn'}
}).connect(mda);


jhu_LUT  = dp_node_segm_jhu();  %LUT
jroi    = dp_node_roi_from_label('jhu_ants_quick', jhu_LUT).connect(aroi);
j_cvs = dp_node_csv('jhu_ants_export','../report/csv', {'mean','n'}).connect(jroi);





