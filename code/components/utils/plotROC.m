function plotROC(svmModel, altModel, classLabels, altName)
svmModel= svmModel.fitPosterior;
[~,svmScore]= svmModel.resubPredict;
[Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(classNames2Bools(classLabels), ...
                            svmScore(:,classNames2Bools(svmModel.ClassNames)),'true');
[~,altScore]= altModel.resubPredict;
[Xalt,Yalt,Talt,AUCalt] = perfcurve(classNames2Bools(classLabels), ...
                            altScore(:,classNames2Bools(altModel.ClassNames)),'true');

figure;
plot(Xsvm,Ysvm); hold on;
plot(Xalt,Yalt);
plot(linspace(Xalt(1),Xalt(end),length(Xalt)), linspace(Yalt(1),Yalt(end),length(Yalt)));
hold off;
xlabel('FPR'); ylabel('TPR');
legend('SVM', altName, 'Random', 'Location','best');
title(['ROC curves for SVM and ',altName]);
fprintf(' (SVM_AUC, alt_AUC)=(%.2f, %.2f)\n', AUCsvm, AUCalt);
end
