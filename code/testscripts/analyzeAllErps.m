clear; close all;
load('data/erp_time_channels.mat');

%% Parameters

erps= {'EPN','N170','P300','LPP'};
dir= 'data/PTES_2/matfilesT';
savefile= 'data/results/features/tmp/svmTrainingSet_';
tresultsfile= 'data/results/svm/tmp/trainResults_';

parameters= struct('filtFrq',[44,52], 'waveMaxFrq',52, ...
                   'voicesPerOct',16, 'waveSmoothStd',1, ...
                   'prominenceThreshold',0.5, ...
                   'selectedPredictors',1:6, 'svmPlotGraphs',false, ...
                   'singlePredictorPerformance',true, ...
                   'singlePredictorPerformThreshold',40 );
genderAnalysis= false;
extractFeatures= true;

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
    saveFeatures([dir,'1/'], savefile1, timeLimits,channels, parameters);
    saveFeatures([dir,'2/'], savefile2, timeLimits,channels, parameters);
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
    [model, err, conf]= trainSvm(savefile1, parameters);
    save(tresultsfile1, 'model','err','conf');

    fprintf('\n-> Training model: T2 %s both\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2, parameters);
    save(tresultsfile2, 'model','err','conf');
  else
    [savefile1_men, savefile1_women]= splitMenWomen(savefile1, 'data/menWomen.mat');
    [savefile2_men, savefile2_women]= splitMenWomen(savefile2, 'data/menWomen.mat');
    tresultsfile1_men=   [tresultsfile1(1:end-4),'_men.mat'];
    tresultsfile1_women= [tresultsfile1(1:end-4),'_women.mat'];
    tresultsfile2_men=   [tresultsfile2(1:end-4),'_men.mat'];
    tresultsfile2_women= [tresultsfile2(1:end-4),'_women.mat'];
    
    fprintf('\n-> Training model: T1 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_men, parameters);
    save(tresultsfile1_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T1 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile1_women, parameters);
    save(tresultsfile1_women, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s MEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_men, parameters);
    save(tresultsfile2_men, 'model','err','conf');
    
    fprintf('\n-> Training model: T2 %s WOMEN\n', erps{erp});
    [model, err, conf]= trainSvm(savefile2_women, parameters);
    save(tresultsfile2_women, 'model','err','conf');
  end
end
