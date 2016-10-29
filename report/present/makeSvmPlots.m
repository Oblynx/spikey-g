close all; clear;
rng(2);
N= [12,12]; s= 0.33; m= [2,1; 1,2];
a= s*randn(N(1),2)+ repmat(m(1,:), N(1),1);
b= s*randn(N(2),2)+ repmat(m(2,:), N(2),1);
%{
figure;
scatter(a(:,1), a(:,2), 80,'k','filled'); hold on;
scatter(b(:,1), b(:,2), 80,'k');
c1= line([1.1,1.5], [3,0], 'Color','m', 'DisplayName', 'c1');
c2= line([0.35,2], [0.65,3], 'Color','b', 'DisplayName', 'c2');
c3= line([0.35,2.2], [0.55,2.7], 'Color','r', 'DisplayName', 'c3');
axis tight;
legend([c1,c2,c3],'Location','best');
hold off;
%}

s= 0.9; m= [3,2; 2,3];
a= s*randn(N(1),2)+ repmat(m(1,:), N(1),1);
b= s*randn(N(2),2)+ repmat(m(2,:), N(2),1);
figure;
scatter(a(:,1), a(:,2), 80,'k','filled'); hold on;
scatter(b(:,1), b(:,2), 80,'k');
c= line([0,5.4], [0,5], 'Color','r', 'DisplayName', 'c');
axis tight;
legend([c],'Location','best');
hold off;
