function cfm= confusion(svm, labels)
% labels in cell array

pred= svm.kfoldPredict;
labels= cellfun(@class2val, labels);
pred= cellfun(@class2val, pred);

truePred= pred == labels;
posPred= pred == 1;
negPred= pred == 0;
tp= sum(truePred & posPred);
tn= sum(truePred & negPred);
fp= sum(~truePred & posPred);
fn= sum(~truePred & negPred);
cfm= [tp,fn;fp,tn];

function v= class2val(x)
if strcmp(x,'bul')
  v= 1;
else
  v= 0;
end
