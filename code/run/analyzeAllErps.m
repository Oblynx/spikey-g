clear; close all;
load('data/erp_time_channels.mat');

%% Parameters
erps= {'EPN','N170','P300','LPP'};
dir= 'data/eeg_experiment/matfilesT';
savefile= 'data/results/features/tmp/svmTrainingSet_';
tresultsfile= 'data/results/svm/tmp/trainResults_';

parameters.feature.preproc= struct( ...
  'channelICA',false, ...
  'channelICAfilt',false, ...
  'filtFrq',[84,92] ...
);
parameters.feature.wave= struct( ...
  'resamplingFactor',1, ...     % Resample eegs before transform (1 does nothing)
  'waveFrq',[4.0,30], ...       % Transform frequency range
  'voicesPerOct',32, ...
  'padmode','zpd', ...
  'mwave', 'morl', ...          % Mother wavelet; must be either 'morl' | 'mexh'
  'waveSmoothStd',0, ...        % UNNECESSARY Smooth before detecting peaks
  'peaksNum',2, ...
  'wavePlot',false...
);
parameters.class.predictor= struct( ...
  'predICA',false, ...                % Perform ICA on predictors
  'predRanking',false, ...            % Rank predictors according to their discriminative ability (via histogram distance)
  'histDist','bhattacharyya', ...     % Histogram distance metric (select any from the 'hist_dist' folder
  'rankSelect',1:4, ...               % If ranking, how many best predictors to keep
  'selectedPredictors',[1,2,4,5] ...  % If ~ranking, which predictors to use
);
parameters.class.svm= struct( ...
  'kernelFunc','rbf', ...
  'k',4, ...
  'svmPlotGraphs',true, ...              % Plot various descriptive graphs
	'singlePredictorPerformance',false, ... % Assess each predictor independently
	'singlePredictorPerformThreshold',50 ...% Show result only if it exceeds this threshold
);
parameters.class.altModel= true;
parameters.gen= struct( ...
  'verbose',1, ...                          % 0= just errors, 1= info, 2= +parameters
  'erpTimeExtension',0, ...                   % Extend ERP time duration by this amount
  'features',3*parameters.feature.wave.peaksNum ...  % READ ONLY!
);

genderAnalysis= false;
extractFeatures= true;

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
  for erp= 1:length(erps)
    tlimName= who(['timeLims_',erps{erp}]);
    chanName= who(['channels_',erps{erp}]);
    timeLimits= eval(tlimName{1});
    channels= eval(chanName{1});

    % Save features using these properties
    savefile1= [savefile,'T1',erps{erp},'.mat'];
    savefile2= [savefile,'T2',erps{erp},'.mat'];
    saveFeatures([dir,'1/'], savefile1, timeLimits,channels, parameters.feature, parameters.gen);
    saveFeatures([dir,'2/'], savefile2, timeLimits,channels, parameters.feature, parameters.gen);
  end
else
  fprintf('--> Feature extraction SKIPPED\n');
end

%% Train SVMs
fprintf('--> Training SVM\n');
for erp= 1:length(erps)
  savefile1=     [savefile,    'T1',erps{erp},'.mat'];
  savefile2=     [savefile,    'T2',erps{erp},'.mat'];
  tresultsfile1= [tresultsfile,'T1',erps{erp},'.mat'];
  tresultsfile2= [tresultsfile,'T2',erps{erp},'.mat'];
  
  if ~genderAnalysis
    fprintf('\n-> Training model: T1 %s both\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1, parameters.class, parameters.gen);
    save(tresultsfile1, 'model','err','conf');

    fprintf('\n-> Training model: T2 %s both\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2, parameters.class, parameters.gen);
    save(tresultsfile2, 'model','err','conf');
  else
    [savefile1_men, savefile1_women]= splitMenWomen(savefile1, 'data/menWomen.mat');
    [savefile2_men, savefile2_women]= splitMenWomen(savefile2, 'data/menWomen.mat');
    tresultsfile1_men=   [tresultsfile1(1:end-4),'_men.mat'];
    tresultsfile1_women= [tresultsfile1(1:end-4),'_women.mat'];
    tresultsfile2_men=   [tresultsfile2(1:end-4),'_men.mat'];
    tresultsfile2_women= [tresultsfile2(1:end-4),'_women.mat'];
    
    fprintf('\n-> Training model: T1 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_men, parameters.class, parameters.gen);
    save(tresultsfile1_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T1 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_women, parameters.class, parameters.gen);
    save(tresultsfile1_women, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_men, parameters.class, parameters.gen);
    save(tresultsfile2_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_women, parameters.class, parameters.gen);
    save(tresultsfile2_women, 'model','err','conf');
  end
end
fprintf('\n');
