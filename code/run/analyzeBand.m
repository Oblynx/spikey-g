%% Analyze band
clear; close all;
loadAll('data/eeg_experiment/sorted_band/');

%% Create Dataset
dsetB= zeros(15*200/6,3);
dsetNB= dsetB;

count= 0;
datanames= who('ptes*Bul');
dataN= length(datanames);
for i=1: dataN
  band= eval(datanames{i});
  band= band(:,7:9);  % Select only the data
  t= size(band,1);
  band= (band - repmat(mean(band,1), t,1)) ./ repmat(std(band,0,1), t,1); % normalize
  band= squeeze(mean(reshape(band,[],6,3),1));           % average for each epoch
  dsetB(count+1: count+size(band,1), :)= band;
  count= count+ size(band,1);
end
dsetB= dsetB(1:count, :);

count= 0;
datanames= who('ptes*Nobul');
dataN= length(datanames);
for i=1: dataN
  band= eval(datanames{i});
  band= band(:,7:9);  % Select only the data
  t= size(band,1);
  band= (band - repmat(mean(band,1), t,1)) ./ repmat(std(band,0,1), t,1); % normalize
  band= squeeze(mean(reshape(band,[],6,3),1));           % average for each epoch
  dsetNB(count+1: count+size(band,1), :)= band;
  count= count+ size(band,1);
end
dsetNB= dsetNB(1:count, :);
clear('ptes*');

dset= [dsetB;dsetNB];
class= cell(size(dset,1),1);
class(1 : size(dsetB,1))= {'bul'};
class(size(dsetB,1)+1 : end)= {'nobul'};

dataToKeep= ~sum(isnan(dset),2);
dset= dset(dataToKeep,:);
class= class(dataToKeep);

classCut= 85; % DANGER %

clear('dsetB','dsetNB','dataToKeep');
%% Show data histograms
% 1: bpm, 2: R, 3: T

figure;
scatterhist(dset(:,1),dset(:,2),'Group',class, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('Heart rate with Resistance'); xlabel('hr'); ylabel('resist');
figure;
scatterhist(dset(:,2),dset(:,3),'Group',class, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('Resistance with Temperature'); xlabel('resist'); ylabel('temp');
figure;
scatterhist(dset(:,3),dset(:,1),'Group',class, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('Temperature with Heart Rate'); xlabel('temp'); ylabel('hr');

%figure;
%scatter3(dset(1:classCut,1),dset(1:classCut,2),dset(1:classCut,3),'xr'); hold on;
%scatter3(dset(classCut+1:end,1),dset(classCut+1:end,2),dset(classCut+1:end,3),'ob'); hold off;

%% Train SVM
svmModel= fitcsvm(dset, class, 'Standardize',true, ...
                  'KernelScale','auto','KernelFunc','rbf');
cvSvmModel= 0;
for i=1:5
  rng(i); cvSvmModel= svmModel.crossval('kfold',4);
  classErrors(i)= 100*cvSvmModel.kfoldLoss;
  %rng(i); cvSvmModel= svmModel.crossval('holdout',0.25);
  %classErrors(i)= 100*cvSvmModel.kfoldLoss;
end
classError= mean(classErrors);     % Mean of 3 independent 4-fold errors (12 folds total)
svmModel= cvSvmModel;
confusMat= confusionMatrix(svmModel, class, true);

% Show classification error
fprintf(' - Classification error: %.1f%% \n', classError);
fprintf('Confusion matrix:\n');
format bank;
disp(confusMat);
format short;
