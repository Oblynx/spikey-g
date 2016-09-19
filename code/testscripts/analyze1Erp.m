clear; close all;
load('data/erp_time_channels.mat');

%% Parameters
dir= 'data/PTES_2/matfilesT1/';
savefile= 'data/results/features/tmp/svmTrainingSet_tmp.mat';
tresultsfile= 'data/results/svm/tmp/trainResults_tmp.mat';

parameters.feature.preproc= struct( ...
  'channelICA',false, ...
  'channelICAfilt',false, ...
  'filtFrq',[84,92] ...
);
parameters.feature.wave= struct( ...
  'waveMaxFrq',30, ...
  'voicesPerOct',32, ...
  'padmode','zpd', ...
  'mwave', 'morl', ...          % must be either 'morl' | 'mexh'
  'waveSmoothStd',0, ...
  'peaksNum',5, ...
  'prominenceThreshold',0.01, ...
  'prominenceUnderflowWarningThreshold', 0 ...
);
parameters.class.predictor= struct( ...
  'predICA',false, ...
  'predRanking',false, ...
  'rankSelect',1:4, ...
  'histDist','bhattacharyya', ...
  'selectedPredictors',[1,2,4,5] ...
);
parameters.class.func= struct( ...
  'svmPlotGraphs',false, ...
	'singlePredictorPerformance',false, ...
	'singlePredictorPerformThreshold',44 ...
);
parameters.gen= struct( ...
  'verbose',1, ...                          % 0= just error, 1= info, 2= +parameters
  'features',3*parameters.feature.wave.peaksNum, ...
  'timeDilation',0.4 ...
);

genderAnalysis= false;
extractFeatures= true;

%timeLimits= [30,150]; % start-end (milliseconds)
%channels= [108,115:117,124:126,137:139,149:151,159];
timeLimits= timeLims_EPN;
channels= channels_ext_EPN;

timeLimits(1)= timeLimits(1) - parameters.gen.timeDilation/2*(timeLimits(2)-timeLimits(1));
timeLimits(2)= timeLimits(2) + parameters.gen.timeDilation/2*(timeLimits(2)-timeLimits(1));
if timeLimits(1) < 0, timeLimits(1)= 0; end
if timeLimits(2) > 800, timeLimits(2)= 800; end

% Show parameters
if parameters.gen.verbose>=2
  fprintf('\tParameters:\n\n');
  disp(parameters.feature.preproc)
  disp(parameters.feature.wave)
  disp(parameters.class.predictor)
  disp(parameters.class.func)
end
%% Extract features
if extractFeatures
  fprintf('--> Extracting features...\n');
  saveFeatures(dir,savefile,timeLimits,channels, parameters.feature, parameters.gen);
else
  fprintf('--> Feature extraction SKIPPED!\n');
end

%% Train SVMs
fprintf('\n--> Training SVMs\n');
if ~genderAnalysis
  fprintf('-> Training model: both genders\n');
  [model, err, conf]= trainSvm(savefile, parameters.class, parameters.gen);
  save(tresultsfile, 'model','err','conf');
else
  [savefile_men, savefile_women]= splitMenWomen(savefile, 'data/menWomen.mat');
  tresultsfile_men=     [tresultsfile(1:end-4),'_men.mat'];
  tresultsfile_women=   [tresultsfile(1:end-4),'_women.mat'];
  % Train men's SVM
  fprintf('-> Training model: MEN\n');
  [model, err, conf]= trainSvm(savefile_men, parameters.class, parameters.gen);
  save(tresultsfile_men, 'model','err','conf');
  % Train women's SVM
  fprintf('\n-> Training model: WOMEN\n');
  [model, err, conf]= trainSvm(savefile_women, parameters.class, parameters.gen);
  save(tresultsfile_women, 'model','err','conf');
end
fprintf('\n');
