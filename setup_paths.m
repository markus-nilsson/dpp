function setup_paths(do_restore_path)
% function setup_paths(do_restore_path)
%
% Restores the default paths and adds all relevant subdirs to the
% path. Run this when you start MATLAB to use the code.
%
% do_restore_path - optional, defaults to true

if (nargin < 1), do_restore_path = 0; end

disp('Setting up paths for the data processing pipeline!');


if (do_restore_path)
    disp('Restoring default path');
    restoredefaultpath;
end

packages_dir = {...
    '.', ...
    'io', ...
    };


t = fileparts(mfilename('fullpath'));

for c_package = 1:numel(packages_dir)
    addpath(fullfile(t, packages_dir{c_package}), '-end');
end

disp '  Done!';

