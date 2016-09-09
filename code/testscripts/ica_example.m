close all; clear;
%rng(1);

%% Sources
t=0:50;
s1= sin(2*pi*0.11*t')+0.1*rand(51,1); s1= s1-mean(s1);
s2= cos(2*pi*0.311*t')+0.1*rand(51,1); s2= s2-mean(s2);
s3= mod(t'/5,2)+0.2*rand(51,1); s3= s3-mean(s3);

%% Source mixing
sources= [s1,s2,s3,rand(51,1)];
a1= sources*[1,2,3,1]';
a2= sources*[1.5,2.5,2,1]';
a3= sources*[1.5,2,2,1]';

figure; subplot(311);plot([s1,s2,s3]);title('s'); subplot(312);plot([a1,a2,a3]);title('a');

%% ICA
srec= ica([a1,a2,a3],3);
subplot(313); plot(srec); title('srec');

%% Originals vs reconstructions
% Find correspondences
sperms= perms([1,2,3]);
for i=1:size(sperms,1)
  err(i)= sum(sum(abs( [s1,s2,s3]-srec(:,sperms(i,:)) )));
end
[~,permi]= min(err);
csp= sperms(permi,:);

figure;
subplot(311);plot([s1,srec(:,csp(1))]); title('s1 vs srec');
subplot(312);plot([s2,srec(:,csp(2))]); title('s2 vs srec');
subplot(313);plot([s3,srec(:,csp(3))]); title('s3 vs srec');

fprintf('errors: %f\t%f\t%f\n', sum(abs(s1-srec(:,csp(1)))), sum(abs(s2-srec(:,csp(2)))), sum(abs(s3-srec(:,csp(3)))));
