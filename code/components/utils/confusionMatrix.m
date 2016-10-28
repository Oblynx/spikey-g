function cfm= confusionMatrix(svm, truth, plot, name)
% cfm= confusionMatrix(svm, truth, plot)
% Calculates the confusion matrix (100*[truePos,falseNeg;falsePos,trueNeg]/total)
% and displays the results graphically
%
% svm: cross-validated SVM model
% truth: cell array of true class labels
% plot: [bool] whether to display the results graphically

pred= svm.kfoldPredict;
truth= classNames2Bools(truth);
pred= classNames2Bools(pred);

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
  plotconfusion(truth,pred, name);  % 1: bul, 2: nobul
end
end
