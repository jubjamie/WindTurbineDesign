folder=fileparts(which(mfilename));
addpath(genpath(folder));
rmpath('.git');
rmpath('docs');
rmpath('codeexamples');
rmpath('.idea');
rmpath('logs');
rmpath('store');