%% Test SVM classification
% TODO: Train 1 SVM per ERP
clear; close all;
rng(1);
numSubjects= 18; waveletImageSmoothing= 1;
svmTrainingSet= zeros(256*numSubjects*2*2,6);  %[channel]*[subject]*[class]*[exper]
svmClassLabels= cell(256*numSubjects*2*2,1);
%% Load all data and prepare the training set 
% Data from experiment 1
loadAll('data/PTES_2/matfilesT1/');
datanames= who('bul*');
for i=1:numSubjects
  f= extractFeatures(eval(datanames{i}), samplingRate, waveletImageSmoothing, []);
  svmTrainingSet(256*(i-1)+1 : 256*i, :)= f;
end
svmClassLabels{1:256*numSubjects}= 'bul';

datanames= who('nobul*');
for i=numSubjects+1 : 2*numSubjects
  f= extractFeatures(eval(datanames{i-numSubjects}), samplingRate, waveletImageSmoothing, []);
  svmTrainingSet(256*(i-1)+1 : 256*i, :)= f;
end
svmClassLabels{256*numSubjects+1 : 256*numSubjects*2}= 'nobul';

% Data from experiment 2
loadAll('data/PTES_2/matfilesT2/');
datanames= who('bul*');
for i=2*numSubjects+1 : 3*numSubjects
  f= extractFeatures(eval(datanames{i-2*numSubjects}), samplingRate, waveletImageSmoothing, []);
  svmTrainingSet(256*(i-1)+1 : 256*i, :)= f;
end
svmClassLabels{256*numSubjects*2+1 : 256*numSubjects*3}= 'bul';

datanames= who('nobul*');
for i=3*numSubjects+1 : 4*numSubjects
  f= extractFeatures(eval(datanames{i-3*numSubjects}), samplingRate, waveletImageSmoothing, []);
  svmTrainingSet(256*(i-1)+1 : 256*i, :)= f;
end
svmClassLabels{256*numSubjects*3+1 : 256*numSubjects*4}= 'nobul';

%% Train SVM
SVMModel = fitcsvm(svmTrainingSet, svmClassLabels, 'Standardize',true, ...
                   'PredictorNames', {'p1_val','p1_fq','p1_wid','p2_val','p2_fq','p2_wid'}, ...
                   'CrossVal', 'on');
