%% svm example
clear
clc
close all;

load fisheriris;
xdata= meas(51:end, 3:4);
group=species(51:end,1);

p=0.5;
[train, test]=crossvalind('HoldOut',group,p);

TrainingSample=xdata(train,:); % ta 1 apo to train 
TrainingLabel=group(train,1);
TestingSample=xdata(test,:);   % ta  apo to test
TestingLabel=group(test,1);

%non linear
%svmStruct= svmtrain(TrainingSample,TrainingLabel, 'showplot', true,'kernel_function','rbf','rbf_sigma',0.1);

%linear
svmStruct= svmtrain(xdata, group, 'showplot', true);

OutLabel= svmclassify(svmStruct, TestingSample,'showplot', true);

%grp2idx(OutLablel)== grp2idx(TestingLabel);
