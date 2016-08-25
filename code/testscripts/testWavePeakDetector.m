clear; close all;
% Params
T= 5; f=1; fs=4*8;

% Make sig
time= linspace(0, T/f, fs*T/f+1); time= time(1:end-1);
freqmod= f*(0.9995+1*exp(-((time-mean(time))).^2));
x= sin(2*pi*freqmod.*time)'*sin(2*pi*freqmod.*time); x= x-min(x(:));
figure; imagesc(x);

p= FastPeakFind(x,1.9,fspecial('gaussian', 7,5),5);
hold on;
plot(p(1:2:length(p)), p(2:2:length(p)), 'rx');
hold off;

