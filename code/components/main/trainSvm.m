function [svmModel, classError, confusMat]= trainSvm(featureFile, params, genparams)
% Loads svm training set & class labels from "featureFile" and trains SVM model

load(featureFile);

%% Preprocess (select, remove NaN...)
fullTset= svmTrainingSet(:,1:genparams.features);
% Remove NaN values
dataToKeep= ~sum(isnan(fullTset),2);
fullTset= fullTset(dataToKeep,:);
svmClassLabels= svmClassLabels(dataToKeep);
classCut= floor(length(svmClassLabels)/2);    % assumes first all bul, then all nobul

%% Predictor ICA
if params.predictor.predICA
  fullTset= ica(fullTset, genparams.features);
end

%% Predictor ranking
if params.predictor.predRanking
  % Calculate histograms
  figure; hold on;
  for pred= 1:genparams.features
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
    histBul{pred}= histObjBul.Values +eps;
    histNobul{pred}= histObjNobul.Values +eps;
    histX{pred}= bedge(1:end-1) + bw/2;     % bin centers
  end
  hold off; close;

  % Calculate discriminative ability of each predictor
  for pred= 1:genparams.features
    discrim(pred)= pdist([histBul{pred};histNobul{pred}],eval(['@',params.predictor.histDist]));
  end
  % Rank predictors according to their discriminative ability
  [~,rankedPred]= sort(discrim, 'descend');
  svmTrainingSet= fullTset(:, rankedPred(params.predictor.rankSelect));
  if genparams.verbose>=1
    fprintf('Best predictors: ');
    disp(rankedPred(params.predictor.rankSelect))
  end
else
  % Else select predictors manually
  svmTrainingSet= fullTset(:, params.predictor.selectedPredictors);
end
%% Calculate statistics
R= corr(fullTset);
if genparams.verbose>=1 && ~params.predictor.predICA;
  fprintf('Peak 1-2 correlation: %.2f\n', R(1,4));
end

%% Plot training set?
if params.svm.svmPlotGraphs
  svmPlotGraphs(fullTset,svmClassLabels,R);
end
%% Train SVM
% Setup SVM training function
trainSvm_ready= 0;
switch params.svm.kernelFunc
  case 'linear'
    trainSvm_ready= @(tset) fitcsvm(tset, svmClassLabels, 'Standardize',true, ...
                              'KernelFunc','linear');
  case {'rbf','gaussian'}
    trainSvm_ready= @(tset) fitcsvm(tset, svmClassLabels, 'Standardize',true, ...
                              'KernelScale','auto','KernelFunc','rbf');
  case 'polynomial'
    trainSvm_ready= @(tset) fitcsvm(tset, svmClassLabels, 'Standardize',true, ...
                              'KernelScale','auto','KernelFunc','polynomial', ...
                              'PolynomialOrder',params.svm.kernelPolynomOrder);
  otherwise
    error('[trainSvm]: Unexpected kernel function!');
end

% Train SVM
svmModel= trainSvm_ready(svmTrainingSet);

% Calculate classification error
%tic;
for i=1:5
  rng(i); cvSvmModel= svmModel.crossval('kfold',params.svm.k);
  classError(i)= 100*cvSvmModel.kfoldLoss;
end
%fprintf('Cross Validation time: %.3f\n', toc);
confusMat= confusionMatrix(cvSvmModel, svmClassLabels, params.svm.svmPlotGraphs, 'SVM');

% Show classification error
fprintf(' - Classification error: %.1f%%\tstd: %.2f \n', mean(classError), std(classError));
if genparams.verbose>=1
  fprintf('Confusion matrix:\n');
  format bank;
  disp(confusMat);
  format short;
end

%% Train and evaluate alternate classification model (naive Bayes)
if params.altModel
  altModel= fitcnb(svmTrainingSet, svmClassLabels, 'DistributionNames','kernel');
  for i= 1:5
    rng(i); cvAltModel= altModel.crossval('kfold',params.svm.k);
    altClassError(i)= 100*cvAltModel.kfoldLoss;
  end
  % Show alt model error
  altConfusMat= confusionMatrix(cvAltModel, svmClassLabels, params.svm.svmPlotGraphs, 'Naive Bayes');
  fprintf(' - Naive Bayes error: %.1f%%\tstd: %.2f \n', mean(altClassError), std(altClassError));
  if genparams.verbose>=1
    fprintf('Naive Bayes confusion matrix:\n');
    format bank;
    disp(altConfusMat);
    format short;
  end
end

% ROC curves
if params.svm.svmPlotGraphs && params.altModel
  plotROC(svmModel, altModel, svmClassLabels, 'Naive Bayes');
end

%% Train and evaluate Decision Tree classifier
if params.altModel
  dtModel= fitctree(svmTrainingSet, svmClassLabels);
  for i= 1:5
    rng(i); cvDtModel= dtModel.crossval('kfold',params.svm.k);
    dtClassError(i)= 100*cvDtModel.kfoldLoss;
  end
  % Show alt model error
  dtConfusMat= confusionMatrix(cvDtModel, svmClassLabels, params.svm.svmPlotGraphs, 'Decision Tree');
  fprintf(' - Decision Tree error: %.1f%%\tstd: %.2f \n', mean(dtClassError), std(dtClassError));
  if genparams.verbose>=1
    fprintf('Decision Tree confusion matrix:\n');
    format bank;
    disp(dtConfusMat);
    format short;
  end
end

% ROC curves
if params.svm.svmPlotGraphs && params.altModel
  plotROC(svmModel, dtModel, svmClassLabels, 'Decision Tree');
end

%% Try each predictor alone
if params.svm.singlePredictorPerformance
  k= 1;
  predNames= {'val','frq','wid'};
  selPreds= nchoosek(1:genparams.features,k);
  fprintf('\n-> Classification errors for using only %d predictor(s)\n', k);
  for i= 1:size(selPreds,1)
    trainingSubset= fullTset(:,selPreds(i,:));
    svmModel= trainSvm_ready(trainingSubset);
    for j=1:3
      rng(j); cvSvmModel= svmModel.crossval('kfold',4);
      classError(j)= 100*cvSvmModel.kfoldLoss;
    end
    classError= mean(classError);
    if classError < params.svm.singlePredictorPerformThreshold
      % Show classification error
      kind= mod(selPreds(i,:)-1,3) +1;
      peak= floor((selPreds(i,:)-1) ./ 3) +1;
      names= '';
      for pred=1:k
        names= [names, predNames{kind(pred)}, int2str(peak(pred)), ' '];
      end
      fprintf('%d: %s= %f\n', i,names,classError);
    end
  end
end

