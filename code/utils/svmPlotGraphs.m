function svmPlotGraphs(trainSet, classLabels, classCut, R)

imagesc(R); title('Pearson correlation'); colorbar;

figure; subplot(2,4,[1 2 5 6]);
gscatter(trainSet(:,1),trainSet(:,4),classLabels,'rk','.');
title('val'); xlabel('val1'); ylabel('val2');
subplot(243); histogram(trainSet(1:classCut,1), 12); title('val1,bul');
subplot(244); histogram(trainSet(1:classCut,4), 12); title('val2,bul');
subplot(247); histogram(trainSet(classCut+1:end,1), 12); title('val1,nobul');
subplot(248); histogram(trainSet(classCut+1:end,4), 12); title('val2,nobul');

figure; subplot(2,4,[1 2 5 6]);
gscatter(trainSet(:,2),trainSet(:,5),classLabels,'rk','.');
title('frq'); xlabel('frq1'); ylabel('frq2');
subplot(243); histogram(trainSet(1:classCut,2), 12); title('frq1,bul');
subplot(244); histogram(trainSet(1:classCut,5), 12); title('frq2,bul');
subplot(247); histogram(trainSet(classCut+1:end,2), 12); title('frq1,nobul');
subplot(248); histogram(trainSet(classCut+1:end,5), 12); title('frq2,nobul');

figure; subplot(2,4,[1 2 5 6]);
gscatter(trainSet(:,3),trainSet(:,6),classLabels,'rk','.');
title('wid'); xlabel('wid1'); ylabel('wid2');
subplot(243); histogram(trainSet(1:classCut,3), 12); title('wid1,bul');
subplot(244); histogram(trainSet(1:classCut,6), 12); title('wid2,bul');
subplot(247); histogram(trainSet(classCut+1:end,3), 12); title('wid1,nobul');
subplot(248); histogram(trainSet(classCut+1:end,6), 12); title('wid2,nobul');
