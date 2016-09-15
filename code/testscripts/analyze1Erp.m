clear; close all;

load('data/erp_time_channels.mat');
dir= 'data/PTES_2/matfilesT1/';
savefile= 'data/results/features/tmp/svmTrainingSet_tmp.mat';
tresultsfile= 'data/results/svm/tmp/trainResults_tmp.mat';

parameters= struct('filtFrq',[44,52], 'waveMaxFrq',52, ...
                   'voicesPerOct',16, 'waveSmoothStd',1, ...
                   'prominenceThreshold',0.5, ...
                   'selectedPredictors',1:6, 'svmPlotGraphs',false, ...
                   'singlePredictorPerformance',true, ...
                   'singlePredictorPerformThreshold',40 );
genderAnalysis= false;
extractFeatures= true;

%timeLimits= [30,150]; % start-end (milliseconds)
%channels= [108,115:117,124:126,137:139,149:151,159];
timeLimits= timeLims_N170;
channels= channels_N170;

% Extract features using these properties
if extractFeatures
  fprintf('--> Extracting features...\n');
  saveFeatures(dir,savefile,timeLimits,channels, parameters);
else
  fprintf('--> Feature extraction SKIPPED!\n');
end


%% Train SVMs
fprintf('\n--> Training SVMs\n');
if ~genderAnalysis
  fprintf('-> Training model: both genders\n');
  [model, err, conf]= trainSvm(savefile, parameters);
  save(tresultsfile, 'model','err','conf');
else
  [savefile_men, savefile_women]= splitMenWomen(savefile, 'data/menWomen.mat');
  tresultsfile_men=   [tresultsfile(1:end-4),'_men.mat'];
  tresultsfile_women=   [tresultsfile(1:end-4),'_women.mat'];
  % Train men's SVM
  fprintf('-> Training model: MEN\n');
  [model, err, conf]= trainSvm(savefile_men, parameters);
  save(tresultsfile_men, 'model','err','conf');
  % Train women's SVM
  fprintf('\n-> Training model: WOMEN\n');
  [model, err, conf]= trainSvm(savefile_women, parameters);
  save(tresultsfile_women, 'model','err','conf');
end