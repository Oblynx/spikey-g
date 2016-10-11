function svmPlotGraphs(trainSet, classLabels, R)

imagesc(R); title('Pearson correlation'); colorbar;

%% Both peaks
figure;
scatterhist(trainSet(:,1),trainSet(:,4),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('val for both peaks'); xlabel('val1'); ylabel('val2');
figure;
scatterhist(trainSet(:,2),trainSet(:,5),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('frq for both peaks'); xlabel('frq1'); ylabel('frq2');
figure;
scatterhist(trainSet(:,3),trainSet(:,6),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('width for both peaks'); xlabel('wid1'); ylabel('wid2');
%% Val-frq
figure;
scatterhist(trainSet(:,1),trainSet(:,2),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('val-frq for peak1'); xlabel('val1'); ylabel('frq1');
figure;
scatterhist(trainSet(:,4),trainSet(:,5),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('val-frq for peak2'); xlabel('val2'); ylabel('frq2');
%% Wid-frq
figure;
scatterhist(trainSet(:,3),trainSet(:,2),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('wid-frq for peak1'); xlabel('wid1'); ylabel('frq1');
figure;
scatterhist(trainSet(:,6),trainSet(:,5),'Group',classLabels, 'Location','SouthEast',...
  'Direction','out','Color','br','Marker','ox','MarkerSize',5);
title('wid-frq for peak2'); xlabel('wid2'); ylabel('frq2');
