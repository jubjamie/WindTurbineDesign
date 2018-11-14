% Script to set up a recursive path in the work dir. Then remove some folders
% MATLAb shouldn't access.
folder=fileparts(which(mfilename));
addpath(genpath(folder));
rmpath('.git');
rmpath('docs');
rmpath('codeexamples');
rmpath('.idea');
rmpath('logs');
rmpath('store');

% Start up parallel processing workers. This can give significant 
% performance increases of up to 8x faster run time.
parpool;