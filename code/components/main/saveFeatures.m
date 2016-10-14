function saveFeatures(dataDir, saveFile, timeLimits, channels, params, genparams)

% May become arguments
fs = 250;
numSubjects= 18;
nFeatures= genparams.features;

%% Extend ERP time limits
if genparams.erpTimeExtension > 0
  timeLimits(1)= timeLimits(1) - genparams.erpTimeExtension/2*(timeLimits(2)-timeLimits(1));
  timeLimits(2)= timeLimits(2) + genparams.erpTimeExtension/2*(timeLimits(2)-timeLimits(1));
  if timeLimits(1) < 0, timeLimits(1)= 0; end
  if timeLimits(2) > 800, timeLimits(2)= 800; end
end


%% Set up variables
% conversion of the times above to sample number. Sample no1 corresponds to
% t=0ms. The interval between two samples is fs/1000 ms.
samples(1)= floor(timeLimits(1)*fs/1000)+1;  % +1 so that if time=0, index=1->first sample
samples(2) = ceil(timeLimits(2)*fs/1000);

% Number of selected channels for each ERP
nChannels= length(channels);

% Test 1 data (1 feature matrix for each ERP)
svmTrainingSet= zeros(nChannels*numSubjects*2,nFeatures+2);  %[channel]*[subject]*[class]=9216
svmClassLabels= cell(nChannels*numSubjects*2,1);   % bul or nobul, for supervised learning

%% Load all data and prepare the training set 
% Data from experiment 1
loadAll(dataDir);   % loads all mat files in specified directory


% get feature vectors for EPN
datanames= who('bul*'); % bul-nobul separation for supervised learning
subjFiller= ones(nChannels,1);
if genparams.verbose>0, tic; end
for i=1:numSubjects
  eegs= eval(datanames{i}); % get all channels of current subject
  eegs= eegs(channels,:);  % get only the period of time corresponding to the current ERP
  eegs= preprocess(eegs, params.preproc);
  
  f= extractFeatures(eegs, samples, fs, params.wave);
  svmTrainingSet(nChannels*(i-1)+1 : nChannels*i, :)= ...
                                    [f,channels',i*subjFiller];
  svmClassLabels(nChannels*(i-1)+1 : nChannels*i)= {'bul'};
end

if genparams.verbose>0, fprintf('[saveFeatures] Time for all subjects, bul: %.2fs\n', toc); end
save(saveFile,'svmTrainingSet','svmClassLabels');

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs= eegs(channels,:);  % get only the period of time corresponding to the current ERP
  eegs= preprocess(eegs, params.preproc);
  
  f= extractFeatures(eegs, samples, fs, params.wave);  % no plotting
  svmTrainingSet(nChannels*(i-1)+1 : nChannels*i, :)= ...
                                    [f,channels',(i-numSubjects)*subjFiller];
  svmClassLabels(nChannels*(i-1)+1 : nChannels*i)= {'nobul'};
end
save(saveFile,'svmTrainingSet','svmClassLabels');


%{
%% Distributed version...
datanames= who('bul*'); % bul-nobul separation for supervised learning
subjFiller= ones(nChannels,1);
%localTset= zeros(nChannels, nFeatures+1, numSubjects);
eegs= zeros(nChannels, 200, numSubjects);
for i=1:numSubjects
  tmpeeg= eval(datanames{i});
  eegs(:,:,i)= tmpeeg(channels,:);
end
eegs= distributed(eegs);
localTset= Composite();
spmd
  eegs= getLocalPart(eegs);
  f= zeros(size(eegs,3),nFeatures);
  for i=1:size(eegs,3);
    eeg= eegs(:,:,i);
    eeg= preprocess(eeg, params.preproc);
    eeg= eeg(:,samples);
    f(i,:)= extractFeatures(eeg, fs,params.wave);
  end
  localTset= [f,channels'];
end
localTset= localTset{:};
svmTrainingSet(1:nChannels*numSubjects, :)= [localTset, reshape(subjFiller*(1:numSubjects),[],1)];
svmClassLabels(1:nChannels*numSubjects)= {'nobul'};

datanames= who('nobul*'); % bul-nobul separation for supervised learning
for i=1:numSubjects
  tmpeeg= eval(datanames{i});
  eegs(:,:,i)= tmpeeg(channels,:);
end
eegs= distributed(eegs); localTset= distributed(localTset);
spmd
  eegs= preprocess(eegs, params.preproc);
  eegs= eegs(:,samples);
  f= extractFeatures(eegs, fs,params.wave);
  localTset= [f,channels'];
end
localTset= gather(localTset); eegs= gather(eegs);
svmTrainingSet(nChannels*numSubjects+1:end, :)= [localTset, reshape(subjFiller*(1:numSubjects),[],1)];
svmClassLabels(nChannels*numSubjects+1:end)= {'nobul'};
save(saveFile,'svmTrainingSet','svmClassLabels');
%}
end
