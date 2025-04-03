
% Put this script in project_name/src, then run it
% It will download necessary MATLAB libraries, and 
% init a suitable project folder structure

% Script assumes git can be called

mkdir ../data
mkdir ../reports
mkdir my_nodes

!git clone https://github.com/markus-nilsson/md-dmri.git
!git clone https://github.com/markus-nilsson/dpp.git

!cp dpp/examples/step1_setup_paths.m ./
!cp dpp/examples/step2_process_data.m ./