% The pipeline is a directed acyclic graph: branches split, merge, and pass structs forward.
% Node = small function-block: expects certain input fields → produces output fields.
% Fields are struct keys (e.g. dmri_fn, bval_fn, labels_fn, fa_fn).
% Branches can fork (parallel nodes) and merge (dp_node_io_merge).
% First you *build the graph*, then you *run actions* on it.

% Common run actions:
%   node.run('report')    % check which inputs/outputs exist
%   node.run('iter')      % list items/IDs the node would process
%   node.run('execute')   % run this node only (skips if outputs exist)
%   node.run_deep('execute') % run this node + all upstream dependencies
%   node.run('mgui');   % collect available *_fn outputs (fa_fn, md_fn, labels_fn, etc.) and view them
%   node.show_pipe();   % Open Pipeline Navigator (shows upstream nodes only)  

% Controls & options:
%   node.run('execute', struct('do_overwrite',1)) % force rerun even if outputs exist
%   node.run('execute', struct('id_filter',{'sub-001','sub-005'})) % run only selected IDs
%   node.run('report', struct('verbose',3))       % verbosity: 0..3
%   node.run('debug')                             % execute without try/catch
%   (same as node.run('execute', struct('do_try_catch',0)))

% === Rerunning after changing fields / wiring ===
% When you add or rename fields (e.g., ad_fn/rd_fn), downstream nodes won’t
% recompute unless you force them:
%   1) node.run('report')                 % verify new fields are present
%   2) affectedNode.run('execute', struct('do_overwrite',1))
%      or affectedNode.run_deep('execute', struct('do_overwrite',1))
% Tip: use id_filter to target subjects; debug to see full errors.
%   node.run('execute', struct('id_filter',{'sub-001'}, 'do_overwrite',1))
%   node.run('debug',   struct('do_overwrite',1))
%   (same as node.run('execute', struct('do_try_catch',0, 'do_overwrite',1)))


% Root to NIfTI data
base_path = '/path/to/nii';

% 1) Subjects → add dmri/xps/op
% 1.1) Primary node: enumerate subject IDs under base_path
%    (use dp_node_io_filter_by_number to select specific subjects if needed)
id1 = my_primary_node(base_path, '*');
% id1 = dp_node_io_filter_by_number(3).connect(id1);  % example: keep only subject #3

% 1.2) Append paths for each subject:
%    dmri_fn → full path to preprocessed dMRI (DTI_dn_mc.nii.gz)
%    xps_fn  → full path to matching XPS file (DTI_dn_mc_xps.mat)
%    op      → output directory for downstream steps (.../tractseg)
id2 = dp_node_io_append({...
    {'dmri_fn', @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc.nii.gz')}, ...
    {'xps_fn',  @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc_xps.mat')}, ...
    {'op',      @(x) fullfile(x.bp, x.id, 'tractseg')}}).connect(id1);

% Sanity check what inputs exist
% id2.run('report');

% 2) b0 → mask
%    dp_node_dmri_subsample_b0: take dmri_fn, find lowest-b (b0), subsample/average → mean b0 (m0_fn)
m0 = dp_node_dmri_subsample_b0().connect(id2);

%    dp_node_segm_hd_bet: run HD-BET on mean b0 → binary brain mask (m1_mask_fn)
m1 = dp_node_segm_hd_bet().connect(m0, 'm1');
% m1.run_deep('execute'); % force run if needed

% 3) xps→bval/bvec, gradcheck
% 3.1) Build bval/bvec from xps (for TractSeg)
%    uses xps_fn from id2; 't0' is just a tag/alias for this branch to avoid field collisions later
t0 = dp_node_dmri_io_xps_to_bval_bvec().connect(id2, 't0');

% 3.2) MRtrix gradcheck (creates *_gc.* copies)
% Wrapper around MRtrix’s dwigradcheck: verifies gradients against the data and flips b-vectors if needed.
% Uses: dmri_fn + bval_fn + bvec_fn (bval/bvec were built in t0; dmri_fn comes from id2/t0 branch)
% Outputs: 
%   → diffusion copy with _gc.nii.gz
%   → corrected bval_gc.txt / bvec_gc.txt
%   → corrected *_gc_xps.mat (updates xps_fn to the corrected scheme)
t1 = dp_node_mrtrix_dwigradcheck().connect(t0);

% 4) merge mask + grads, alias mask
% 4.1) Merge gradchecked data with mask; keep original field names
%    dp_node_io_merge combines fields from multiple nodes so later steps have all inputs:
%      - From t1: dmri_fn, bval_fn, bvec_fn, xps_fn (grad-checked)
%      - From m1: m1_mask_fn (brain mask)
%    t1 carries the diffusion data + corrected bvals/bvecs; m1 carries the mask.
t2 = dp_node_io_merge({t1, m1});

%    Keep “plain” names (no t1_ / m1_ prefixes) to match downstream expectations.
t2.do_prefix = 0;

% 4.2) Rename mask field so TractSeg sees it as mask_fn
%    After merging, the mask is still named m1_mask_fn (from the HD-BET node),
%    but the TractSeg node expects mask_fn. This is a field alias, no file is created.
t3 = dp_node_io('mask_fn', 'm1_mask_fn').connect(t2);

% 5) TractSeg (MNI outputs: Diffusion_MNI, FA_MNI, nodif_brain_mask_MNI, bundles.nii.gz)
%    Uses the TractSeg container (wasserth/tractseg_container:master) with 
%    --raw_diffusion_input and --preprocess (handles registration to MNI).
% Inputs: dmri_fn, bval_fn, bvec_fn, and optionally mask_fn
% Outputs (written into <op>):
%    Diffusion_MNI.nii.gz (4D resampled diffusion data)
%    FA_MNI.nii.gz
%    nodif_brain_mask_MNI.nii.gz
%    bundles.nii.gz (4D stack wrapping all bundle_segmentations_MNI/*.nii.gz)
t4 = dp_node_segm_tractseg().connect(t3);
% t4.run('report', struct('verbose',3));

% 6) DTI (LLS) on TractSeg s MNI-space diffusion data (b_delta = 1) into subfolder <op>/dti_lls
% Read dmri_fn + bval_fn + bvec_fn from t4 (dmri_fn now points to Diffusion_MNI.nii.gz;
% bval/bvec are the grad-checked ones carried from t1).
% The argument 1 sets b_delta = 1 (linear tensor encoding) in the XPS it creates.
% Output: xps_fn that matches those bvals/bvecs and the current dmri_fn.
dti1 = dp_node_dmri_xps_from_bval_bvec(1).connect(t4);

% Override the output folder for downstream nodes:
% set op = <bp>/<id>/tractseg/dti_lls so DTI maps land in a tidy subfolder.
dti2 = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg', 'dti_lls')).connect(dti1);

% Perform DTI (LLS) using dmri_fn, xps_fn, and mask (if present).
% Forwards input.opt to dti_lls_opt → dti_lls_pipe, so extra maps can be enabled if the pipe supports them.
dti3 = dp_node_dmri_dti().connect(dti2);

% 7) Expose DTI map paths for downstream use (files confirmed by your folder listing)

% After DTI fit the pipe writes several maps into <op>/dti_lls:
%   dti_lls_ad.nii.gz     → axial diffusivity (λ1)
%   dti_lls_rd.nii.gz     → radial diffusivity ((λ2+λ3)/2)
%   dti_lls_md.nii.gz     → mean diffusivity
%   dti_lls_fa.nii.gz     → fractional anisotropy
%   dti_lls_s0.nii.gz     → baseline signal (S0)
%   dti_lls_fa_u_rgb.nii.gz → FA color map (RGB, direction-encoded)
%   dti_lls_dps.mat       → diffusion parameter structure (MATLAB struct of scalars)
%   dti_lls_mfs.mat       → model fit structure (fitted tensor parameters)

% Some of these are already exposed, but we add AD and RD as fields for later steps.
% dti3 = dp_node_io_append({ ...
%   {'fa_fn', @(x) fullfile(x.op, 'dti_lls_fa.nii.gz')}, ...
%   {'md_fn', @(x) fullfile(x.op, 'dti_lls_md.nii.gz')}, ...
%   {'ad_fn', @(x) fullfile(x.op, 'dti_lls_ad.nii.gz')}, ...
%   {'rd_fn', @(x) fullfile(x.op, 'dti_lls_rd.nii.gz')}, ...
%   {'s0_fn', @(x) fullfile(x.op, 'dti_lls_s0.nii.gz')} ...
% }).connect(dti3);

% Check inputs and outputs
% dti3.run('report', struct('verbose',1));
% or 
% disp(dti3.input_test);  
% disp(dti3.output_test); 

% Add only the missing fields (AD/RD). FA/MD/S0 already exist.
dti3_append = dp_node_io_append({
  {'ad_fn', @(x) fullfile(x.op, 'dti_lls_ad.nii.gz')}, ...
  {'rd_fn', @(x) fullfile(x.op, 'dti_lls_rd.nii.gz')}
}).connect(dti3);
% check with dti3.run('report', struct('verbose',2));

% 8) Merge DTI maps with TractSeg outputs; keep names unprefixed
%     Combines fields from dti3 and t4 for intersecting subject IDs.
%     Keeps plain names (fa_fn, md_fn, labels_fn, …) instead of dti3_fa_fn / t4_labels_fn.
mx = dp_node_io_merge({dti3_append, t4});  mx.do_prefix = 0;

% 9) Whitelist exactly what the ROI step needs (labels + selected scalars)
%     Map TractSeg labels to labels_fn and pass through MD/FA/AD/RD/S0.
%     This keeps the ROI input clean and predictable.
roi_in = dp_node_io_rename({
  {'labels_fn','labels_fn'}, ...
  {'fa_fn','fa_fn'}, ...
  {'md_fn','md_fn'}, ...
  {'ad_fn','ad_fn'}, ...
  {'rd_fn','rd_fn'}, ...
  {'s0_fn','s0_fn'}
}).connect(mx);

% 10) ROIs from TractSeg bundles → CSV (mean + count)
% Convert label volumes → per-bundle ROIs, then export CSV (mean + n)
%    dp_node_roi_from_label builds ROIs from a label volume and extracts stats from all *_fn 3D maps (except labels_fn).
%    Expects:
%      - labels_fn: a 3D label map or a 4D stack (each 4th-dim volume = one bundle). TractSeg writes bundles.nii.gz (4D).
%      - Metric maps (3D): e.g., fa_fn, md_fn, ad_fn, rd_fn, s0_fn.
%
%    'tractseg' here is just a label-set identifier (a nickname). It can be any string.
%    Passing t4 tells the ROI node which bundle names/IDs correspond to the volumes in bundles.nii.gz.
t6 = dp_node_roi_from_label('tractseg', t4).connect(roi_in);

% ROI stats available: n, mean, std, median, mad,
%   quantile_1st/5th/10th/25th/50th/75th/90th/95th/99th
% Choose which to export via dp_node_csv(..., {'mean','n', ...}).
% Optional 4th arg 'fields' filters which metric maps to export.
% By default, all *_fn maps from roi_in are written (fa_fn, md_fn, ad_fn, rd_fn, s0_fn, ...).
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

% ----------------------------------
% Visualizing the pipeline
% Each node can display the upstream pipeline, e.g., for A→B→C: C.show_pipe() → A–B–C; 
% B.show_pipe() → A–B; A.show_pipe() → A.
%
% Use:
% my_node.show_pipe();
%
% This opens the Pipeline Navigator GUI:
%
% * Pipeline panel: shows all nodes and their connections as a directed graph.
% * Inputs panel: lists available subjects/IDs (empty if no data yet).
% * Properties/fields: inspect input/output fields of the selected node.
% * Log: shows run messages.
%
% Notes:
%
% * The diagram is built purely from how nodes are connected – it works even without data.
% * The Inputs panel may stay empty (or give harmless warnings) if no data is available.
% * To export the graph programmatically instead of the GUI, use:
%
%   G = my_node.get_graph();   % returns a MATLAB digraph
%   plot(G)


% ====================== Pipeline schematic =======================
% 
% base_path
%    |
%    v
% id1  --(subjects)-------------------------------------------------------------.
%    |                                                                           \
%    v                                                                            \
% id2  [append dmri_fn, xps_fn, op=.../tractseg]                                   \
%    |                                                                              \
%    |----------------------------- b0/mask branch ----------------------------------.
%    |                                                                               |
%    v                                                                               v
%  m0  = dp_node_dmri_subsample_b0()      t0 = dp_node_dmri_io_xps_to_bval_bvec()  (build bval/bvec)
%    |                                                                               |
%    v                                                                               v
%  m1  = dp_node_segm_hd_bet() (m1_mask_fn)   t1 = dp_node_mrtrix_dwigradcheck() (dmri_fn,bval_fn,bvec_fn,xps_fn _gc)
%    \___________________________________________/ 
%                    merge
%                      |
%                      v
%  t2 = dp_node_io_merge({t1,m1});  (dmri_fn,bval_fn,bvec_fn,xps_fn + m1_mask_fn)   [do_prefix=0]
%                      |
%                      v
%  t3 = dp_node_io('mask_fn','m1_mask_fn')   (alias mask_fn for downstream)
%                      |
%                      v
%  t4 = dp_node_segm_tractseg()  -->  bundles.nii.gz (4D), FA_MNI.nii.gz, nodif_brain_mask_MNI.nii.gz, Diffusion_MNI.nii.gz
%                      |
%                      |-------------- DTI branch on MNI ---------------------------.
%                      v                                                            |
%  dti1 = dp_node_dmri_xps_from_bval_bvec(1)  (make xps_fn; b_delta=1)              |
%                      |                                                            |
%  dti2 = dp_node_io('op', .../tractseg/dti_lls)  (set output folder)               |
%                      |                                                            |
%  dti3 = dp_node_dmri_dti()  --> dti_lls_{fa,md,s0,ad,rd,fa_u_rgb}.nii.gz          |
%                      |                                                            |
%  dti3 = dp_node_io_append({ad_fn, rd_fn, s0_fn, fa_fn, md_fn})  (expose paths) <--'
%                      |
%          .-----------' 
%          |
%          v
%  mx = dp_node_io_merge({dti3, t4})   (DTI maps + TractSeg labels in one struct)   [do_prefix=0]
%          |
%          v
%  roi_in = dp_node_io_rename({labels_fn<-labels_fn, fa_fn, md_fn, ad_fn, rd_fn, s0_fn})
%          |
%          v
%  t6 = dp_node_roi_from_label('tractseg', t4)   (compute per-bundle stats over all *_fn maps)
%          |
%          v
%  t7 = dp_node_csv('tractseg_export','../report/csv', {'mean','n'})   (export CSV)
%
% Legend:
%  -> data/fields flow
%  merge: dp_node_io_merge joins branches (keep names with do_prefix=0)
%  alias: dp_node_io('mask_fn','m1_mask_fn') renames a field for downstream nodes
