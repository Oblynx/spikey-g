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
  svmPlotGraphs(fullTset,svmClassLabels,classCut,R);
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
for i=1:3
  rng(i); cvSvmModel= svmModel.crossval('kfold',4);
  classError(i)= 100*cvSvmModel.kfoldLoss;
end
%fprintf('Cross Validation time: %.3f\n', toc);
classError= mean(classError);     % Mean of 3 independent 4-fold errors (12 folds total)
svmModel= cvSvmModel;
confusMat= confusionMatrix(svmModel, svmClassLabels, params.svm.svmPlotGraphs);

% Show classification error
fprintf(' - Classification error: %.1f%% \n', classError);
if genparams.verbose>=1
  fprintf('Confusion matrix:\n');
  format bank;
  disp(confusMat);
  format short;
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
