clear; close all;
load('data/PTES_2/matfilesT1/ptes02 20160704 1141.T1.-0.mat');
x=bul_Averageptes02;
fs=250;

[w,pf]= eegcwt(x(1,:), fs, 8, 'morl','image');
%{
[m,M]= findExtrema(w);
xm= zeros(sum(sum(m)),1); ym= xm; xM= zeros(sum(sum(M)),1); yM= xM; cm=1; cM=1;
for i=1:size(m,1)
  for j=1:size(m,2)
    if m(i,j)==1
      xm(cm)= i; ym(cm)= j;
    end
    if M(i,j)==1
      xM(cM)= i; yM(cM)= j;
    end
  end
end
figure;imagesc((0:200)/fs,pf,w);
hold on;
plot(xm,ym,'ro'); plot(xM,yM,'bx'); hold off;
%}
p= FastPeakFind(w,max(w(:))*0.6);
figure; imagesc(w); hold on
plot(p(1:2:end),p(2:2:end),'r+')
