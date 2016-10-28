function cfm= confusionMatrix(svm, truth, plot)
% cfm= confusionMatrix(svm, truth, plot)
% Calculates the confusion matrix (100*[truePos,falseNeg;falsePos,trueNeg]/total)
% and displays the results graphically
%
% svm: cross-validated SVM model
% truth: cell array of true class labels
% plot: [bool] whether to display the results graphically

pred= svm.kfoldPredict;
truth= cellfun(@class2val, truth);
pred= cellfun(@class2val, pred);

truePred= pred == truth;
posPred= pred == 1;       % 1: bul
negPred= pred == 0;       % 0: nobul
tp= sum(truePred & posPred);
tn= sum(truePred & negPred);
fp= sum(~truePred & posPred);
fn= sum(~truePred & negPred);

setSize= length(pred);
cfm= round(100.*[tp,fp;fn,tn]./setSize,2);

if plot
  truth= [~truth, truth]'; truth= ~truth;
  pred= [~pred, pred]'; pred= ~pred;
  figure;
  plotconfusion(truth,pred);  % 1: bul, 2: nobul
end
end

function v= class2val(x)
if strcmp(x,'bul')
  v= 1;
else
  v= 0;
end
end
