clear; close all;

%% Extract features
load('data/erp_time_channels.mat');
erps= {'EPN','N170','P300','LPP'};
dir= 'data/PTES_2/matfilesT';
savefile= 'data/results/features/tmp/svmTrainingSet_';
tresultsfile= 'data/results/svm/tmp/trainResults_';

for erp= 1:length(erps)
  tlimName= who(['timeLims_',erps{erp}]);
  chanName= who(['channels_',erps{erp}]);
  timeLimits= eval(tlimName{1});
  channels= eval(chanName{1});
  
  % Save features using these properties
  savefile1= [savefile,'T1',erps{erp},'.mat'];
  savefile2= [savefile,'T2',erps{erp},'.mat'];
  saveFeatures([dir,'1/'], savefile1, timeLimits,channels,0);
  saveFeatures([dir,'2/'], savefile2, timeLimits,channels,0);
end

%% Train SVMs
for erp= 1:length(erps)
  savefile1=     [savefile,    'T1',erps{erp},'.mat'];
  savefile2=     [savefile,    'T2',erps{erp},'.mat'];
  tresultsfile1= [tresultsfile,'T1',erps{erp},'.mat'];
  tresultsfile2= [tresultsfile,'T2',erps{erp},'.mat'];
  
  fprintf('-> Training model: T1 %s\n', erps{erp});
  [model, err, conf]= trainSvm(savefile1);
  save(tresultsfile1, 'model','err','conf');
  
  fprintf('-> Training model: T2 %s\n', erps{erp});
  [model, err, conf]= trainSvm(savefile2);
  save(tresultsfile2, 'model','err','conf');
end
