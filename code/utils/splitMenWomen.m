function [savefile_men, savefile_women]= splitMenWomen(savefile, menwomenfile)
% [savefile_men, savefile_women]= splitMenWomen(savefile, menwomenfile)
% 
%  Splits the observations in 'savefile' into men/women parts, according to the
%  split contained in 'menwomenfile'.
%
% savefile: Contains 'svmClassLabels' and 'svmTrainingSet', whose last column is the
%   subject index
% menwomenfile: Contains 'men' and 'women' vectors, which assign each subject to
%   a category

load(savefile); load(menwomenfile);

% Split men/women
menInSvm= ismember(svmTrainingSet(:,end), men);
womenInSvm= ismember(svmTrainingSet(:,end), women);

svmTrainingSet_men= svmTrainingSet(menInSvm,:);
svmClassLabels_men= svmClassLabels(menInSvm,:);
svmTrainingSet_women= svmTrainingSet(womenInSvm,:);
svmClassLabels_women= svmClassLabels(womenInSvm,:);

% Save results
if strcmp(savefile(end-3:end), '.mat')
  savefile_men= [savefile(1:end-4),'_men.mat'];
  savefile_women= [savefile(1:end-4),'_women.mat'];
else
  savefile_men= [savefile,'_men.mat'];
  savefile_women= [savefile,'_women.mat'];
end
svmTrainingSet= svmTrainingSet_men; svmClassLabels= svmClassLabels_men;
save(savefile_men, 'svmTrainingSet','svmClassLabels');
svmTrainingSet= svmTrainingSet_women; svmClassLabels= svmClassLabels_women;
save(savefile_women, 'svmTrainingSet','svmClassLabels');
