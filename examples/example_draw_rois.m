
% connect to data
base_path = 'your_data';
project_name = 'your_project';
id0 = dp_node_primary_list_lund(base_path, project_name);

id1 = dp_node_io_rename({...
    {'op', @(x) fullfile(x.bp, x.id, 'DTI')}, ...
    {'md_fn', @(x) fullfile(x.opt, 'DTI_MD.nii.gz')}, ...
    }).connect(id0);

id1.do_rename_immediately = 1;

% prepare to draw lesions ROIs
roi = dp_node_roi('my_roi', '../data/roi', {'lesion'}).connect(id1);
roi.roi_use_single = 1;

% save results to csv file
csv = dp_node_csv('csv', '../reports/csv', {'mean', 'median'}, 'md_fn').connect(roi);