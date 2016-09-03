% Compute all feature vectors to set up experiment 
%% Parameters
% train 8 SVMs : 4 ERPs * 2 experiments

fs = 250;
numSubjects= 18;
waveletImageSmoothing= 1; % std for gaussian filter in image smoothing for peak detection

% Time bounds for ERPs (in ms)
EPN_lower = 30;
EPN_upper = 150;
N170_lower = 130;
N170_upper = 210;
P300_lower = 230;
P300_upper = 370;
LPP_lower = 400;
LPP_upper = 700;

% Selected channels for each ERP
channEPN= [];
channN170= [];
channP300= [];
channLPP= [];

%% Set up variables
% conversion of the times above to sample number. Sample no1 corresponds to
% t=0ms. The interval between two samples is fs/1000 ms.
EPN_lower = floor(EPN_lower*fs/1000)+1;  % +1 so that if time=0, index=1->first sample
EPN_upper = ceil(EPN_upper*fs/1000);
N170_lower = floor(N170_lower*fs/1000)+1; % ceil->round to closest integer towards positive infinity
N170_upper = ceil(N170_upper*fs/1000);  % floor->round to closest integer towards negative infinity
P300_lower = floor(P300_lower*fs/1000)+1;
P300_upper = ceil(P300_upper*fs/1000);
LPP_lower = floor(LPP_lower*fs/1000)+1;
LPP_upper = ceil(LPP_upper*fs/1000);

% Number of selected channels for each ERP
nChannEPN= length(channEPN);
nChannN170= length(channN170);
nChannP300= length(channP300);
nChannLPP= length(channLPP);

% Test 1 data (1 feature matrix for each ERP)
svmTrainingSetT1_EPN= zeros(nChannEPN*numSubjects*2,6);  %[channel]*[subject]*[class]=9216
svmClassLabelsT1_EPN= cell(nChannEPN*numSubjects*2,1);   % bul or nobul, for supervised learning

svmTrainingSetT1_N170= zeros(nChannN170*numSubjects*2,6);
svmClassLabelsT1_N170= cell(nChannN170*numSubjects*2,1);

svmTrainingSetT1_P300= zeros(nChannP300*numSubjects*2,6);
svmClassLabelsT1_P300= cell(nChannP300*numSubjects*2,1);

svmTrainingSetT1_LPP= zeros(nChannLPP*numSubjects*2,6);
svmClassLabelsT1_LPP= cell(nChannLPP*numSubjects*2,1);

% Test 2 data
svmTrainingSetT2_EPN= zeros(nChannEPN*numSubjects*2,6);
svmClassLabelsT2_EPN= cell(nChannEPN*numSubjects*2,1);

svmTrainingSetT2_N170= zeros(nChannN170*numSubjects*2,6);
svmClassLabelsT2_N170= cell(nChannN170*numSubjects*2,1);

svmTrainingSetT2_P300= zeros(nChannP300*numSubjects*2,6);
svmClassLabelsT2_P300= cell(nChannP300*numSubjects*2,1);

svmTrainingSetT2_LPP= zeros(nChannLPP*numSubjects*2,6);
svmClassLabelsT2_LPP= cell(nChannLPP*numSubjects*2,1);

%% Load all data and prepare the training set 
% Data from experiment 1
loadAll('data/PTES_2/matfilesT1/');   % loads all mat files in specified directory

% get feature vectors for EPN
datanames= who('bul*'); % bul-nobul separation for supervised learning
for i=1:numSubjects
  eegs = eval(datanames{i}); % get all channels of current subject
  eegs = eegs(channEPN,EPN_lower:EPN_upper);  % get only the period of time corresponding to the current ERP
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);  % no plotting
  svmTrainingSetT1_EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= f;
  svmClassLabelsT1_EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'bul'};  % den douleuei ayth h entolh. kalytera na enswmatosoyme 7o stoixeio, 1->bul, 0->nobul giati an kanoume random anakatema den tha xreiazetai na vriskoume pali poios einai bul kai poios oxi
  save svmTrainingSetT1_EPN.mat svmTrainingSetT1_EPN svmClassLabelsT1_EPN ; % save every subject completed not to lose data. that should be 5 mins of computer time lost maximum
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channEPN,EPN_lower:EPN_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= f;
  svmClassLabelsT1_EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'nobul'}; % den douleuei
  save svmTrainingSetT1_EPN.mat svmTrainingSetT1_EPN svmClassLabelsT1_EPN ;
end

% get feature vectors for N170
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channN170,N170_lower:N170_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_N170(nChannN170*(i-1)+1 : nChannN170*i, :)= f;
  svmClassLabelsT1_N170(nChannN170*(i-1)+1 : nChannN170*i)= {'bul'};
  save svmTrainingSetT1_N170.mat svmTrainingSetT1_N170 svmClassLabelsT1_N170 ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channN170,N170_lower:N170_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_N170(nChannN170*(i-1)+1 : nChannN170*i, :)= f;
  svmClassLabelsT1_N170(nChannN170*(i-1)+1 : nChannN170*i)= {'nobul'};
  save svmTrainingSetT1_N170.mat svmTrainingSetT1_N170 svmClassLabelsT1_N170 ;
end

% get feature vectors for P300
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channP300,P300_lower:P300_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_P300(nChannP300*(i-1)+1 : nChannP300*i, :)= f;
  svmClassLabelsT1_P300(nChannP300*(i-1)+1 : nChannP300*i)= {'bul'};
  save svmTrainingSetT1_P300.mat svmTrainingSetT1_P300 svmClassLabelsT1_P300 ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channP300,P300_lower:P300_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_P300(nChannP300*(i-1)+1 : nChannP300*i, :)= f;
  svmClassLabelsT1_P300(nChannP300*(i-1)+1 : nChannP300*i)= {'nobul'};
  save svmTrainingSetT1_P300.mat svmTrainingSetT1_P300 svmClassLabelsT1_P300 ;
end

% get feature vectors for LPP
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channLPP,LPP_lower:LPP_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_LPP(nChannLPP*(i-1)+1 : nChannLPP*i, :)= f;
  svmClassLabelsT1_LPP(nChannLPP*(i-1)+1 : nChannLPP*i)= {'bul'};
  save svmTrainingSetT1_LPP.mat svmTrainingSetT1_LPP svmClassLabelsT1_LPP ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channLPP,LPP_lower:LPP_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT1_LPP(nChannLPP*(i-1)+1 : nChannLPP*i, :)= f;
  svmClassLabelsT1_LPP(nChannLPP*(i-1)+1 : nChannLPP*i)= {'nobul'};
  save svmTrainingSetT1_LPP.mat svmTrainingSetT1_LPP svmClassLabelsT1_LPP ;
end


% Data from experiment 2
%clear
loadAll('data/PTES_2/matfilesT2/');

% get feature vectors for EPN
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i});
  eegs = eegs(channEPN,EPN_lower:EPN_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= f;
  svmClassLabelsT2_EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'bul'};
  save svmTrainingSetT2_EPN.mat svmTrainingSetT2_EPN svmClassLabelsT2_EPN ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channEPN,EPN_lower:EPN_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_EPN(nChannEPN*(i-1)+1 : nChannEPN*i, :)= f;
  svmClassLabelsT2_EPN(nChannEPN*(i-1)+1 : nChannEPN*i)= {'nobul'};
  save svmTrainingSetT2_EPN.mat svmTrainingSetT2_EPN svmClassLabelsT2_EPN ;
end

% get feature vectors for N170
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channN170,N170_lower:N170_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_N170(nChannN170*(i-1)+1 : nChannN170*i, :)= f;
  svmClassLabelsT2_N170(nChannN170*(i-1)+1 : nChannN170*i)= {'bul'};
  save svmTrainingSetT2_N170.mat svmTrainingSetT2_N170 svmClassLabelsT2_N170 ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channN170,N170_lower:N170_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_N170(nChannN170*(i-1)+1 : nChannN170*i, :)= f;
  svmClassLabelsT2_N170(nChannN170*(i-1)+1 : nChannN170*i)= {'nobul'};
  save svmTrainingSetT2_N170.mat svmTrainingSetT2_N170 svmClassLabelsT2_N170 ;
end

% get feature vectors for P300
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channP300,P300_lower:P300_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_P300(nChannP300*(i-1)+1 : nChannP300*i, :)= f;
  svmClassLabelsT2_P300(nChannP300*(i-1)+1 : nChannP300*i)= {'bul'};
  save svmTrainingSetT2_P300.mat svmTrainingSetT2_P300 svmClassLabelsT2_P300 ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channP300,P300_lower:P300_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_P300(nChannP300*(i-1)+1 : nChannP300*i, :)= f;
  svmClassLabelsT2_P300(nChannP300*(i-1)+1 : nChannP300*i)= {'nobul'};
  save svmTrainingSetT2_P300.mat svmTrainingSetT2_P300 svmClassLabelsT2_P300 ;
end

% get feature vectors for LPP
datanames= who('bul*');
for i=1:numSubjects
  eegs = eval(datanames{i}); 
  eegs = eegs(channLPP,LPP_lower:LPP_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_LPP(nChannLPP*(i-1)+1 : nChannLPP*i, :)= f;
  svmClassLabelsT2_LPP(nChannLPP*(i-1)+1 : nChannLPP*i)= {'bul'};
  save svmTrainingSetT2_LPP.mat svmTrainingSetT2_LPP svmClassLabelsT2_LPP ;
end

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  eegs = eval(datanames{i-numSubjects});
  eegs = eegs(channLPP,LPP_lower:LPP_upper);
  f= extractFeatures(eegs, samplingRate, waveletImageSmoothing, []);
  svmTrainingSetT2_LPP(nChannLPP*(i-1)+1 : nChannLPP*i, :)= f;
  svmClassLabelsT2_LPP(nChannLPP*(i-1)+1 : nChannLPP*i)= {'nobul'};
  save svmTrainingSetT2_LPP.mat svmTrainingSetT2_LPP svmClassLabelsT2_LPP ;
end
