function [svmModel, error, confusMat]= trainSvm(featureFile)
% Loads svm training set & class labels from "featureFile" and trains SVM model

load(featureFile);

%% Preprocess (select, remove NaN...)
fullTset= svmTrainingSet(:,1:6);
% Remove NaN values
dataToKeep= ~sum(isnan(fullTset),2);
fullTset= fullTset(dataToKeep,:);
svmClassLabels= svmClassLabels(dataToKeep);

% PCA into a lower-dimensional space. Data not linearly separable in < 3 dims
%{
[~, fullTset]= pcares(zscore(fullTset), 2);
fullTset= fullTset(:,1:2);
%}
%c= pca(fullTset);
%fullTset= fullTset*c(1:3,:)';

%% Calculate statistics
R= corr(fullTset);% R= (R>0.75) + 0.5*(R<=0.75 & R>=0.25);
classCut= floor(length(svmClassLabels)/2);

%% Plot training set?
close all;
imagesc(R); title('Pearson correlation'); colorbar;

figure; subplot(2,4,[1 2 5 6]);
gscatter(fullTset(:,1),fullTset(:,4),svmClassLabels,'rk','.');
title('val'); xlabel('val1'); ylabel('val2');
subplot(243); histogram(fullTset(1:classCut,1), 12); title('val1,bul');
subplot(244); histogram(fullTset(1:classCut,4), 12); title('val2,bul');
subplot(247); histogram(fullTset(classCut+1:end,1), 12); title('val1,nobul');
subplot(248); histogram(fullTset(classCut+1:end,4), 12); title('val2,nobul');

figure; subplot(2,4,[1 2 5 6]);
gscatter(fullTset(:,2),fullTset(:,5),svmClassLabels,'rk','.');
title('frq'); xlabel('frq1'); ylabel('frq2');
subplot(243); histogram(fullTset(1:classCut,2), 12); title('frq1,bul');
subplot(244); histogram(fullTset(1:classCut,5), 12); title('frq2,bul');
subplot(247); histogram(fullTset(classCut+1:end,2), 12); title('frq1,nobul');
subplot(248); histogram(fullTset(classCut+1:end,5), 12); title('frq2,nobul');

figure; subplot(2,4,[1 2 5 6]);
gscatter(fullTset(:,3),fullTset(:,6),svmClassLabels,'rk','.');
title('wid'); xlabel('wid1'); ylabel('wid2');
subplot(243); histogram(fullTset(1:classCut,3), 12); title('wid1,bul');
subplot(244); histogram(fullTset(1:classCut,6), 12); title('wid2,bul');
subplot(247); histogram(fullTset(classCut+1:end,3), 12); title('wid1,nobul');
subplot(248); histogram(fullTset(classCut+1:end,6), 12); title('wid2,nobul');

figure;
%% Train SVM
svmTrainingSet= fullTset(:,[2,3,5,6]);
tic;
svmModel= fitcsvm(svmTrainingSet, svmClassLabels, 'Standardize',true, ...
                   'KernelScale','auto','KernelFunc','rbf');
fprintf('Training time: %.2f\n',toc);
% Calculate classification error
tic;
for i=1:3
  rng(i); cvSvmModel= svmModel.crossval('kfold',4);
  error(i)= 100*cvSvmModel.kfoldLoss;
end
fprintf('CV time: %.3f\n', toc);
error= mean(error); % Mean of 3 independent 4-fold errors (12 folds total)
svmModel= cvSvmModel;
confusMat= confusionMatrix(svmModel, svmClassLabels, true);

% Show classification error
fprintf('Classification error: %.1f%% \n', error);
fprintf('Confusion matrix:\n');
format bank;
disp(confusMat);
format short;


%% Try each predictor alone
k= 1;
predNames= {'val1 ','frq1 ','wid1 ', ...
            'val2 ','frq2 ','wid2 '};
selPreds= nchoosek(1:6,k);
fprintf('-> Show classification errors for using only %d predictor(s)\n', k);
for i= 1:size(selPreds,1)
  trainingSubset= fullTset(:,selPreds(i,:));
  svmModel= fitcsvm(trainingSubset, svmClassLabels, 'Standardize',true, ...
                     'KernelScale','auto','KernelFunc','rbf');
  for j=1:3
    rng(j); cvSvmModel= svmModel.crossval('kfold',4);
    error(j)= 100*cvSvmModel.kfoldLoss;
  end
  error= mean(error);
  if error < 38
    % Show classification error
    fprintf('%s= %f\n',[predNames{selPreds(i,:)}],error);
  end
end
%}

