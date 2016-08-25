function [fv]= extractFeatures(eeg, wsmooth)
% eeg: [channel]x[time] Part of eeg time series from which the characteristics
% of the 2 most prominent wavelet peaks will be extracted

[w,pf]= eegcwt(x(1,:), fs, 8, 'morl','image');
for i= 1:size(w,3)
  w(:,:,i)= imgaussfilt(w(:,:,i),wsmooth);
end

