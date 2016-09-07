function cfm= confusionMatrix(svm, truth, plot)
% labels in cell array

pred= svm.kfoldPredict;
truth= cellfun(@class2val, truth);
pred= cellfun(@class2val, pred);

truePred= pred == truth;
posPred= pred == 1;
negPred= pred == 0;
tp= sum(truePred & posPred);
tn= sum(truePred & negPred);
fp= sum(~truePred & posPred);
fn= sum(~truePred & negPred);
cfm= [tp,fn;fp,tn];

if plot
  truth= [~truth, truth]';
  pred= [~pred, pred]';
  plotconfusion(truth,pred);
end
end

function v= class2val(x)
if strcmp(x,'bul')
  v= 1;
else
  v= 0;
end
end
