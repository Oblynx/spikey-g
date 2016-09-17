function [svmModel, error, confusMat]= trainSvm(featureFile, params)
% Loads svm training set & class labels from "featureFile" and trains SVM model

load(featureFile);

%% Preprocess (select, remove NaN...)
fullTset= svmTrainingSet(:,1:6);
% Remove NaN values
dataToKeep= ~sum(isnan(fullTset),2);
fullTset= fullTset(dataToKeep,:);
svmClassLabels= svmClassLabels(dataToKeep);
classCut= floor(length(svmClassLabels)/2);

%% Predictor ICA
if params.predictor.predICA
  fullTset= ica(fullTset, 6);
end

%% Predictor ranking
if params.predictor.predRanking
  % Calculate histograms
  figure; hold on;
  for pred= 1:6
    histObjBul= histogram(fullTset(1:classCut,pred), 'Normalization','Probability');
    histObjNobul= histogram(fullTset(classCut+1:end,pred), 'Normalization','Probability');
    % Normalize x axis
    bw= min([histObjBul.BinWidth, histObjNobul.BinWidth]);
    bmax= max([ histObjBul.BinEdges, histObjNobul.BinEdges]);
    bmin= min([ histObjBul.BinEdges, histObjNobul.BinEdges]);
    bedge= bmin:bw:bmax;
    if bedge(end) < bmax, bedge= [bedge, bedge(end)+bw]; end
    histObjBul.BinWidth= bw; histObjNobul.BinWidth= bw;
    histObjBul.BinEdges= bedge; histObjNobul.BinEdges= bedge;
    % Get histogram values
    histBul{pred}= histObjBul.Values;
    histNobul{pred}= histObjNobul.Values;
    histX{pred}= bedge(1:end-1) + bw/2;     % bin centers
  end

  % Calculate discriminative ability of each predictor
  for pred= 1:6
    discrim(pred)= kldiv(histX{pred}, histBul{pred}, histNobul{pred}, 'sym');
  end
  % Rank predictors according to their discriminative ability
  [~,rankedPred]= sort(discrim, 'descend');
  svmTrainingSet= fullTset(:, rankedPred(1:params.predictor.numPred));
else
  svmTrainingSet= fullTset(:, params.predictor.selectedPredictors);
end
%% Calculate statistics
R= corr(fullTset);
fprintf('Peak correlation: %.2f\n', R(1,4));

%% Plot training set?
if params.func.svmPlotGraphs
  svmPlotGraphs(fullTset,svmClassLabels,classCut,R);
end
%% Train SVM
%tic;
svmModel= fitcsvm(svmTrainingSet, svmClassLabels, 'Standardize',true, ...
                   'KernelScale','auto','KernelFunc','rbf');
%fprintf('Training time: %.2f\n',toc);

% Calculate classification error
%tic;
for i=1:3
  rng(i); cvSvmModel= svmModel.crossval('kfold',4);
  error(i)= 100*cvSvmModel.kfoldLoss;
end
%fprintf('Cross Validation time: %.3f\n', toc);
error= mean(error); % Mean of 3 independent 4-fold errors (12 folds total)
svmModel= cvSvmModel;
confusMat= confusionMatrix(svmModel, svmClassLabels, params.func.svmPlotGraphs);

% Show classification error
fprintf(' - Classification error: %.1f%% \n', error);
fprintf('Confusion matrix:\n');
format bank;
disp(confusMat);
format short;

%% Try each predictor alone
if params.func.singlePredictorPerformance
  k= 1;
  predNames= {'val1 ','frq1 ','wid1 ', ...
              'val2 ','frq2 ','wid2 '};
  selPreds= nchoosek(1:6,k);
  fprintf('-> Classification errors for using only %d predictor(s)\n', k);
  for i= 1:size(selPreds,1)
    trainingSubset= fullTset(:,selPreds(i,:));
    svmModel= fitcsvm(trainingSubset, svmClassLabels, 'Standardize',true, ...
                       'KernelScale','auto','KernelFunc','rbf');
    for j=1:3
      rng(j); cvSvmModel= svmModel.crossval('kfold',4);
      error(j)= 100*cvSvmModel.kfoldLoss;
    end
    error= mean(error);
    if error < params.func.singlePredictorPerformThreshold
      % Show classification error
      fprintf('%s= %f\n',[predNames{selPreds(i,:)}],error);
    end
  end
end

