function loadAll(local_datadir)
% Loads all variables from all mat files in the specified dir to the caller's
% workspace. Don't forget the trailing slash on the dir name!
% Example: loadAll('data/PTES_2/matfilesT1/');

local_datanames= dir([local_datadir,'*.mat']);
for local_i=1:size(local_datanames,1)
  load([local_datadir,local_datanames(local_i).name]);
end
clear('local_datadir','local_datanames','local_i');
local_varnames= who('*');
for local_i=1 : length(local_varnames)
  assignin('caller', local_varnames{local_i}, eval(local_varnames{local_i}));
end
