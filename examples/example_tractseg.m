% Root to NIfTI data
base_path = '/path/to/nii';

% 1) Subjects → add dmri/xps/op
id1 = my_primary_node(base_path, '*');
id2 = dp_node_io_append({...
  {'dmri_fn', @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc.nii.gz')}, ...
  {'xps_fn',  @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc_xps.mat')}, ...
  {'op',      @(x) fullfile(x.bp, x.id, 'tractseg')}}).connect(id1);

% 2) b0 → mask
m0 = dp_node_dmri_subsample_b0().connect(id2);
m1 = dp_node_segm_hd_bet().connect(m0, 'm1');

% 3) xps→bval/bvec, gradcheck
t0 = dp_node_dmri_io_xps_to_bval_bvec().connect(id2, 't0');
t1 = dp_node_mrtrix_dwigradcheck().connect(t0);

% 4) merge mask + grads, alias mask
t2 = dp_node_io_merge({t1, m1}); t2.do_prefix = 0;
t3 = dp_node_io('mask_fn', 'm1_mask_fn').connect(t2);

% 5) TractSeg (MNI outputs: Diffusion_MNI, FA_MNI, nodif_brain_mask_MNI, bundles.nii.gz)
t4 = dp_node_segm_tractseg().connect(t3);

% 6) DTI (LLS) on TractSeg’s MNI-space diffusion data (b_delta = 1) into subfolder <op>/dti_lls
dti1 = dp_node_dmri_xps_from_bval_bvec(1).connect(t4);
dti2 = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg', 'dti_lls')).connect(dti1);
dti3 = dp_node_dmri_dti().connect(dti2);

% Check inputs and outputs
% dti3.run('report', struct('verbose',1));
% or 
% disp(dti3.input_test);  
% disp(dti3.output_test); 

% 7) Expose DTI map paths for downstream use (files confirmed by your folder listing)
% dti3_append = dp_node_io_append({ ...
%   {'fa_fn', @(x) fullfile(x.op, 'dti_lls_fa.nii.gz')}, ...
%   {'md_fn', @(x) fullfile(x.op, 'dti_lls_md.nii.gz')}, ...
%   {'ad_fn', @(x) fullfile(x.op, 'dti_lls_ad.nii.gz')}, ...
%   {'rd_fn', @(x) fullfile(x.op, 'dti_lls_rd.nii.gz')}, ...
%   {'s0_fn', @(x) fullfile(x.op, 'dti_lls_s0.nii.gz')} ...
% }).connect(dti3);

% Add only the missing fields (AD/RD). FA/MD/S0 already exist.
dti3_append = dp_node_io_append({
  {'ad_fn', @(x) fullfile(x.op, 'dti_lls_ad.nii.gz')}, ...
  {'rd_fn', @(x) fullfile(x.op, 'dti_lls_rd.nii.gz')}
}).connect(dti3);


% 8) Merge DTI maps + TractSeg outputs (keep plain names)
mx = dp_node_io_merge({dti3_append, t4}); mx.do_prefix = 0;

% 9) Whitelist inputs for ROI stats (labels + selected scalars)
%    Note: labels_fn and fa_fn already exist on t4; DTI scalars come from dti3.
roi_in = dp_node_io_rename({
  {'labels_fn','labels_fn'}, ...
  {'fa_fn','fa_fn'}, ...
  {'md_fn','md_fn'}, ...
  {'ad_fn','ad_fn'}, ...
  {'rd_fn','rd_fn'}, ...
  {'s0_fn','s0_fn'}
}).connect(mx);

% 10) ROIs from TractSeg bundles → CSV (mean + count)
t6 = dp_node_roi_from_label('tractseg', t4).connect(roi_in);
t7 = dp_node_csv('tractseg_export','../report/csv', {'mean','n'}).connect(t6);


% --- direct branch (FA-only from TractSeg) ---
% Demonstrates how a pipeline can fork: one branch uses DTI+TractSeg maps,
% while another goes directly from TractSeg FA_MNI to ROI/CSV.

roi_in_2 = dp_node_io_rename({
  {'labels_fn','labels_fn'}, ...   % bundles.nii.gz from t4
  {'fa_fn','fa_fn'}               % FA_MNI.nii.gz from t4
}).connect(t4);  

t6_2 = dp_node_roi_from_label('tractseg', t4).connect(roi_in_2);

% distinct CSV name + filter to FA only
t7_2 = dp_node_csv('tractseg_fa_only','../report/csv', {'mean','n'}, {'fa_fn'}).connect(t6_2);

% run (force recompute stats/CSV after wiring changes):
% t6.run('execute', struct('do_overwrite',1));
% t7.run('execute', struct('do_overwrite',1));
