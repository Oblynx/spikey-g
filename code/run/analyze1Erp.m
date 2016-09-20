clear; close all;
load('data/erp_time_channels.mat');

%% Parameters
dir= 'data/eeg_experiment/matfilesT1/';                         % Data directory
savefile= 'data/results/features/tmp/svmTrainingSet_tmp.mat';   % Where to save features
tresultsfile= 'data/results/svm/tmp/trainResults_tmp.mat';      % Where to save SVM results

parameters.feature.preproc= struct( ...
  'channelICA',false, ...
  'channelICAfilt',false, ...
  'filtFrq',[84,92] ...
);
parameters.feature.wave= struct( ...
  'resamplingFactor',1, ...     % Resample eegs before transform (1 does nothing)
  'waveFrq',[4.5,30], ...       % Transform frequency range
  'voicesPerOct',16, ...
  'padmode','zpd', ...
  'mwave', 'morl', ...          % Mother wavelet; must be either 'morl' | 'mexh'
  'waveSmoothStd',0, ...        % Smooth before detecting peaks; unnecessary
  'peaksNum',4, ...
  'wavePlot',false ...
);
parameters.class.predictor= struct( ...
  'predICA',false, ...          % Perform ICA on predictors
  'predRanking',true, ...       % Rank predictors according to their discriminative ability (via histogram distance)
  'histDist','bhattacharyya', ...     % Histogram distance metric (select any from the 'hist_dist' folder
  'rankSelect',1:4, ...               % If ranking, how many best predictors to keep
  'selectedPredictors',[1,2,4,5] ...  % If ~ranking, which predictors to use
);
parameters.class.svm= struct( ...
  'kernelFunc','rbf', ...
  'svmPlotGraphs',false, ...              % Plot various descriptive graphs
	'singlePredictorPerformance',false, ... % Assess each predictor independently
	'singlePredictorPerformThreshold',44 ...% Show result only if it exceeds this threshold
);
parameters.gen= struct( ...
  'verbose',1, ...                          % 0= just errors, 1= info, 2= +parameters
  'erpTimeExtension',0.4, ...                   % Extend ERP time duration by this amount
  'features',3*parameters.feature.wave.peaksNum ...  % READ ONLY!
);

genderAnalysis= false;
extractFeatures= true;

%timeLimits= [30,150]; % start-end (milliseconds)
%channels= [108,115:117,124:126,137:139,149:151,159];
timeLimits= timeLims_EPN;
channels= channels_EPN;

%% Show parameters?
if parameters.gen.verbose>=2
  fprintf('\tParameters:\n\n');
  disp(parameters.feature.preproc)
  disp(parameters.feature.wave)
  disp(parameters.class.predictor)
  disp(parameters.class.svm)
  disp(parameters.gen)
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
