
% connect to data
base_path = '../data';
pattern = 'project_name_*';
id = dp_node_primary_list_folder(base_path, pattern);

id.run('report'); % build your pipeline from here