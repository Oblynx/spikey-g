function analyzeERPCombinations(resavefile)
%% ERP combinations
savefile= 'data/results/features/tmp/svmTrainingSet_';

load([savefile,'combEPN']);
tsetEPN= svmTrainingSet;

load([savefile,'combN170']);
tsetN170= svmTrainingSet;

svmTrainingSet= [tsetEPN(:,1:3), tsetN170(:,1:3)];
save(resavefile, 'svmTrainingSet','svmClassLabels');
