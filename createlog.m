function [logid,logstamp] = createlog(title)
%CREATELOG Opens a log file and puts in system info in header.

mydir  = pwd; % Get working directory
idcs   = strfind(mydir,filesep); % Split path to array
newdir = mydir(1:idcs(end)-1); % set log directory level up.
% Make datestamp
logstamp=datestr(now,'yyyy-mm-dd--HH-MM-SS');

% Write and open a log file nameed as above.
logid=fopen(strcat(newdir,'/logs/',logstamp ,'.log'), 'a');
% Printer system/run info to header.
fprintf(logid,'---%s---\r\n',title);
fprintf(logid,'Log created at: %s\r\n',logstamp);
fprintf(logid,'Created by %s on %s\r\n',getenv('username'),...
    getenv('computername'));
fprintf(logid,'Computer: %s\r\n',getenv('computername'));
fprintf(logid,'OS: %s\r\n',getenv('os'));
fprintf(logid,'Processors: %s\r\n',getenv('number_of_processors'));
fprintf(logid,'Threads: %s\r\n',getenv('omp_num_threads'));
end