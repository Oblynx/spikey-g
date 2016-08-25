function [f]= extractFeatures(eeg, fs, wsmooth)
% eeg: [channel]x[time] Part of eeg time series from which the characteristics
% of the 2 most prominent wavelet peaks will be extracted

close all;
t= (0:size(eeg,2))/fs;
[w,pfreq]= eegcwt(eeg, fs, 8, 'morl','image');
% Normalized energy for each coefficient
for i= 1:size(w,3)
  x= w(:,:,i);
  x= abs(x.*x);
  w(:,:,i)= 100*x./sum(x(:));
end

for i= 1:size(w,3)
  x= w(:,:,i);
  x= imgaussfilt(x,wsmooth);
  %{
  p= FastPeakFind(x,max([min(max(x,[],1))  min(max(x,[],2))]), ...
                  fspecial('gaussian', 10,2),5);
  peaks= [p(1:2:end), p(2:2:end)];
  figure; imagesc(x);
  hold on; plot(peaks(:,1),peaks(:,2), 'rx');
  %}
  [zM,iM]= extrema2(x);
  p= selectPeaks(x,iM, 0.2);
  %figure; imagesc(flipud(x)); axis xy;
  hold on; plot(t(p(:,1)), size(x,1)-p(:,2), 'rx');
end

function p= selectPeaks(x, i, promThresh)
medx= median(x(:));
[i(:,2), i(:,1)]= ind2sub(size(x), i);
p(1,:)= i(1,:);
for ii=2:length(i)
  xr= i(1,1):i(ii,1);
  if isempty(xr)
    xr= i(1,1):-1:i(ii,1);
  end
  yr= round(linspace(i(1,2),i(ii,2), length(xr)));
  ir= sub2ind(size(x),yr,xr);
  candidate= x(ir(end));
  % prominence of a peak: how the depth of the valley between the 2 peaks
  % compares to the median level of the image. 0 means no valley, 1 is a valley
  % as deep as the signal median
  prominence= (candidate-min(x(ir)))/(candidate-medx);
  if prominence > promThresh
    p(2,:)= i(ii,:);
    break;
  end
end

