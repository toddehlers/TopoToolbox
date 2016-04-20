% Main function for TopoToolBox
% Written by Willi Kappler, (C) 2016
%

% Change current directory to where the main.m file is located:
cd(fileparts(mfilename('fullpath')));

% Adds the current folder and all subfolder to the search path:
addpath(genpath('.'));

% Run the main application:
app = topoapp();
