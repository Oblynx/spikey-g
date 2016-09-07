function saveFeatures(dataDir, saveFile, timeLimits, channels, wltSmoothStd)

% May become variables
fs = 250;
numSubjects= 18;

%% Set up variables
% conversion of the times above to sample number. Sample no1 corresponds to
% t=0ms. The interval between two samples is fs/1000 ms.
samples(1)= floor(timeLimits(1)*fs/1000)+1;  % +1 so that if time=0, index=1->first sample
samples(2) = ceil(timeLimits(2)*fs/1000);
samples= samples(1):samples(2);

% Number of selected channels for each ERP
nChannels= length(channels);

% Test 1 data (1 feature matrix for each ERP)
svmTrainingSet= zeros(nChannels*numSubjects*2,8);  %[channel]*[subject]*[class]=9216
svmClassLabels= cell(nChannels*numSubjects*2,1);   % bul or nobul, for supervised learning

%% Load all data and prepare the training set 
% Data from experiment 1
loadAll(dataDir);   % loads all mat files in specified directory

% get feature vectors for EPN
datanames= who('bul*'); % bul-nobul separation for supervised learning
subjFiller= ones(nChannels,1);
tic;
for i=1:numSubjects
  eegs = eval(datanames{i}); % get all channels of current subject
  eegs = eegs(channels,samples);  % get only the period of time corresponding to the current ERP
  f= extractFeatures(eegs, fs, wltSmoothStd, []);  % no plotting
  svmTrainingSet(nChannels*(i-1)+1 : nChannels*i, :)= ...
                                    [f,channels',i*subjFiller];
  svmClassLabels(nChannels*(i-1)+1 : nChannels*i)= {'bul'};
end
toc
save(saveFile,'svmTrainingSet','svmClassLabels');

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channels,samples);
  f= extractFeatures(eegs, fs, wltSmoothStd, []);
  svmTrainingSet(nChannels*(i-1)+1 : nChannels*i, :)= ...
                                    [f,channels',(i-numSubjects)*subjFiller];
  svmClassLabels(nChannels*(i-1)+1 : nChannels*i)= {'nobul'};
end
save(saveFile,'svmTrainingSet','svmClassLabels');

end
