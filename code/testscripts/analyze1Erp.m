clear; close all;

load('data/erp_time_channels.mat');
dir= 'data/PTES_2/matfilesT1/';
savefile= 'data/results/features/tmp/svmTrainingSet_tmp.mat';
tresultsfile= 'data/results/svm/tmp/trainResults_tmp.mat';

parameters= struct('filtFrq',[44,52], 'waveMaxFrq',52, ...
                   'voicesPerOct',16, 'waveSmoothStd',1, ...
                   'prominenceThreshold',0.5, ...
                   'selectedPredictors',1:6 );

%timeLimits= [30,150]; % start-end (milliseconds)
%channels= [108,115:117,124:126,137:139,149:151,159];
timeLimits= timeLims_N170;
channels= channels_N170;

% Save features using these properties
saveFeatures(dir,savefile,timeLimits,channels, parameters);


%% WARNING
%[savefile_men, savefile_women]= splitMenWomen(savefile, 'data/menWomen.mat');
% Train men's SVM
[model, err, conf]= trainSvm(savefile, parameters);
save(tresultsfile, 'model','err','conf');
% Train women's SVM
%[model, err, conf]= trainSvm(savefile_women);
%save(tresultsfile, 'model','err','conf');
