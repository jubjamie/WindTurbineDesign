function [logid] = createlog(title)
%CREATELOG Summary of this function goes here
%   Detailed explanation goes here
mydir  = pwd;
idcs   = strfind(mydir,filesep);
newdir = mydir(1:idcs(end)-1);
logstamp=datestr(now,'HH-MM-SS--yyyy-mm-dd');
logid=fopen(strcat(newdir,'/logs/',logstamp ,'.log'), 'a');
fprintf(logid,'---%s---\r\n',title);
fprintf(logid,'Log created at: %s\r\n',logstamp);
fprintf(logid,'Created by %s on %s\r\n',getenv('username'),getenv('computername'));
fprintf(logid,'Computer: %s\r\n',getenv('computername'));
fprintf(logid,'OS: %s\r\n',getenv('os'));
fprintf(logid,'Processors: %s\r\n',getenv('number_of_processors'));
fprintf(logid,'Threads: %s\r\n',getenv('omp_num_threads'));
end

