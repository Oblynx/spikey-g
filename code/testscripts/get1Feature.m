clear; close all;
%% Parameters
% train 8 SVMs : 4 ERPs * 2 experiments

fs = 250;
numSubjects= 18;
wltSmoothStd= 1; % std for gaussian filter in image smoothing for peak detection

% Time bounds for ERPs (in ms)
EPN_lower = 30;
EPN_upper = 150;

% Selected channels for each ERP
channEPN= [108,115:117,124:126,137:139,149:151,159];

%% Set up variables
% conversion of the times above to sample number. Sample no1 corresponds to
% t=0ms. The interval between two samples is fs/1000 ms.
EPN_lower = floor(EPN_lower*fs/1000)+1;  % +1 so that if time=0, index=1->first sample
EPN_upper = ceil(EPN_upper*fs/1000);

% Number of selected channels for each ERP
nChannEPN= length(channEPN);

% Test 1 data (1 feature matrix for each ERP)
svmTrainingSet_T1EPN= zeros(nChannEPN*numSubjects*2,7);  %[channel]*[subject]*[class]=9216
svmClassLabels_T1EPN= cell(nChannEPN*numSubjects*2,1);   % bul or nobul, for supervised learning

%% Load all data and prepare the training set 
% Data from experiment 1
loadAll('data/PTES_2/matfilesT2/');   % loads all mat files in specified directory

% get feature vectors for EPN
datanames= who('bul*'); % bul-nobul separation for supervised learning
for i=1:numSubjects
  eegs = eval(datanames{i}); % get all channels of current subject
  eegs = eegs(channEPN,EPN_lower:EPN_upper);  % get only the period of time corresponding to the current ERP
  tic;
  f= extractFeatures(eegs, samplingRate, wltSmoothStd, []);  % no plotting
  toc
  svmTrainingSet_T1EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= [f,channEPN'];
  svmClassLabels_T1EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'bul'};  % den douleuei ayth h entolh. kalytera na enswmatosoyme 7o stoixeio, 1->bul, 0->nobul giati an kanoume random anakatema den tha xreiazetai na vriskoume pali poios einai bul kai poios oxi
  save data/results/features/svmTrainingSet_T1all.mat svmTrainingSet_T1EPN svmClassLabels_T1EPN; % save every subject completed not to lose data. that should be 5 mins of computer time lost maximum
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channEPN,EPN_lower:EPN_upper);
  f= extractFeatures(eegs, samplingRate, wltSmoothStd, []);
  svmTrainingSet_T1EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= [f,channEPN'];
  svmClassLabels_T1EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'nobul'}; % den douleuei
  save data/results/features/svmTrainingSet_T1all.mat svmTrainingSet_T1EPN svmClassLabels_T1EPN;
end

