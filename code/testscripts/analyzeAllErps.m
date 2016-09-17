clear; close all;
load('data/erp_time_channels.mat');

%% Parameters
erps= {'EPN','N170','P300','LPP'};
dir= 'data/PTES_2/matfilesT';
savefile= 'data/results/features/tmp/svmTrainingSet_';
tresultsfile= 'data/results/svm/tmp/trainResults_';

parameters= struct('feature',[], 'class',[]);
parameters.feature= struct('preproc',[], 'wave',[]);
parameters.class= struct('predictor',[], 'func',[]);

parameters.feature.preproc= struct( ...
  'channelICA',false, ...
  'channelICAfilt',false, ...
  'filtFrq',[84,92] ...
);
parameters.feature.wave= struct( ...
  'waveMaxFrq',90, ...
  'voicesPerOct',32, ...
  'waveSmoothStd',2, ...
  'prominenceThreshold',0.5 ...
);
parameters.class.predictor= struct( ...
  'predICA',true, ...
  'predRanking',true, ...
  'numPred',3, ...
  'selectedPredictors',1:6 ...
);
parameters.class.func= struct( ...
  'svmPlotGraphs',false, ...
	'singlePredictorPerformance',true, ...
	'singlePredictorPerformThreshold',48 ...
);

genderAnalysis= false;
extractFeatures= true;

%% Extract features
parameters
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
    saveFeatures([dir,'1/'], savefile1, timeLimits,channels, parameters.feature);
    saveFeatures([dir,'2/'], savefile2, timeLimits,channels, parameters.feature);
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
    [model, err, conf]= trainSvm(savefile1, parameters.class);
    save(tresultsfile1, 'model','err','conf');

    fprintf('\n-> Training model: T2 %s both\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2, parameters.class);
    save(tresultsfile2, 'model','err','conf');
  else
    [savefile1_men, savefile1_women]= splitMenWomen(savefile1, 'data/menWomen.mat');
    [savefile2_men, savefile2_women]= splitMenWomen(savefile2, 'data/menWomen.mat');
    tresultsfile1_men=   [tresultsfile1(1:end-4),'_men.mat'];
    tresultsfile1_women= [tresultsfile1(1:end-4),'_women.mat'];
    tresultsfile2_men=   [tresultsfile2(1:end-4),'_men.mat'];
    tresultsfile2_women= [tresultsfile2(1:end-4),'_women.mat'];
    
    fprintf('\n-> Training model: T1 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_men, parameters.class);
    save(tresultsfile1_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T1 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_women, parameters.class);
    save(tresultsfile1_women, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_men, parameters.class);
    save(tresultsfile2_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_women, parameters.class);
    save(tresultsfile2_women, 'model','err','conf');
  end
end
fprintf('\n');
