function plotROC(svmModel, altModel, classLabels)
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
legend('SVM', 'Naive Bayes', 'Random', 'Location','best');
title('ROC curves for SVM and naive Bayes');
fprintf(' (SVM_AUC, nb_AUC)=(%.2f, %.2f)\n', AUCsvm, AUCalt);
end
