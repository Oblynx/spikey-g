clear; close all;

dir= 'data/PTES_2/matfilesT2/';
savefile= 'data/results/features/svmTrainingSet_T1EPN.mat';
timeLimits= [30,150]; % start-end (milliseconds)
channels= [108,115:117,124:126,137:139,149:151,159];
% Save features using these properties
saveFeatures(dir,savefile,timeLimits,channels,0);

