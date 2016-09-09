clear; close all;

load('data/erp_time_channels.mat');
dir= 'data/PTES_2/matfilesT1/';
savefile= 'data/results/features/svmTrainingSet_tmp.mat';
tresultsfile= 'data/results/svm/trainResults_tmp.mat';

%timeLimits= [30,150]; % start-end (milliseconds)
%channels= [108,115:117,124:126,137:139,149:151,159];
timeLimits= timeLims_N170;
channels= channels_N170;

% Save features using these properties
saveFeatures(dir,savefile,timeLimits,channels,0);


%% WARNING
[model, err, conf]= trainSvm(savefile);
save(tresultsfile, 'model','err','conf');
