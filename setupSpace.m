% Script to set up a recursive path in teh work dir. Then remove some folders
% MATLAb shouldn't access.
folder=fileparts(which(mfilename));
addpath(genpath(folder));
rmpath('.git');
rmpath('docs');
rmpath('codeexamples');
rmpath('.idea');
rmpath('logs');
rmpath('store');