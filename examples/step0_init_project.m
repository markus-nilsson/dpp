
% Put this script in project_name/src, then run it
% It will download necessary MATLAB libraries, and 
% init a suitable project folder structure

% Script assumes git can be called

mkdir ../data
mkdir ../reports

!git clone https://github.com/markus-nilsson/md-dmri.git
!git clone https://github.com/markus-nilsson/dpp.git

