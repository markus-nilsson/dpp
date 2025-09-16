
% Connect to data from custom node
base_path = '../data';
id1 = my_primary_node(base_path, '*');

% Connect to already processed data, put output data in tractseg folder
id2 = dp_node_io_append({...
    {'dmri_fn', @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc.nii.gz')}, ...
    {'xps_fn', @(x) fullfile(x.bp, x.id, 'DWI', 'DTI_dn_mc_xps.mat')}}).connect(id1);

id3 = dp_node_io('op', @(x) fullfile(x.bp, x.id, 'tractseg')).connect(id2); 

% id2.run('report'); % checks which subjects have their files are present


% Mask the b0
m0 = dp_node_dmri_subsample_b0().connect(id3);
m1 = dp_node_segm_hd_bet().connect(m0).set_name('m1');


% Run tractseg
t0 = dp_node_dmri_io_xps_to_bval_bvec().connect(id3).set_name('t0');

t1 = dp_node_mrtrix_dwigradcheck().connect(t0);

t2 = dp_node_io_merge({t1, m1});
t2.do_prefix = 0;

t3 = dp_node_io('mask_fn', 'm1_mask_fn').connect(t2);

t4 = dp_node_segm_tractseg().connect(t3);

t5 = dp_node_io_rename({ ...
    {'labels_fn', 'labels_fn'}, ...
    {'fa_fn', 'fa_fn'}}).connect(t4);

t6 = dp_node_roi_from_label('tractseg', t4).connect(t5);

t7 = dp_node_csv('tractseg_export', '../report/csv', {'mean'}).connect(t6);

