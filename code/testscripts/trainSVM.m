%% Train SVM
clear; close all;
load data/results/features/svmTrainingSet_T1EPN.mat

fullTset= svmTrainingSet_T1EPN(:,1:6);
% Remove NaN values
dataToKeep= ~sum(isnan(fullTset),2);
fullTset= fullTset(dataToKeep,:);
svmClassLabels_T1EPN= svmClassLabels_T1EPN(dataToKeep);

% PCA into a lower-dimensional space. Data not linearly separable in < 3 dims
%{
[~, fullTset]= pcares(zscore(fullTset), 2);
fullTset= fullTset(:,1:2);
%}
%c= pca(fullTset);
%fullTset= fullTset*c(1:3,:)';

svmTrainingSet_T1EPN= fullTset;
svmModel_T1EPN = fitcsvm(svmTrainingSet_T1EPN, svmClassLabels_T1EPN, 'Standardize',true, ...
                   'CrossVal', 'on', 'kfold',5);
% Show classification error
fprintf('Classification error: %.1f%% \n', 100*svmModel_T1EPN.kfoldLoss);
fprintf('Confusion matrix:\n');
disp(confusion(svmModel_T1EPN, svmClassLabels_T1EPN))
%silhouette(fullTset, kmeans(fullTset,2,'Replicates',5))

%{
% Try each predictor alone
predNames= {'p1_val;','p1_fq;','p1_wid;','p2_val;','p2_fq;','p2_wid;'};
selPreds= nchoosek(1:6,2);
for i= 1:size(selPreds,1)
  svmTrainingSet_T1EPN= fullTset(:,selPreds(i,:));
  svmModel_T1EPN = fitcsvm(svmTrainingSet_T1EPN, svmClassLabels_T1EPN, 'Standardize',true, ...
                     'CrossVal', 'on');
  % Show classification error
  fprintf('%s= %f\n',[predNames{selPreds(i,:)}],svmModel_T1EPN.kfoldLoss);
end
%}

