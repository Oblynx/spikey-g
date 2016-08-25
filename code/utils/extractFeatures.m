function [f]= extractFeatures(eeg, fs, wsmooth, plottype)
% eeg: [channel]x[time] Part of eeg time series from which the characteristics
% of the 2 most prominent wavelet peaks will be extracted

close all;
t= (0:size(eeg,2))/fs;
[w,pfreq]= eegcwt(eeg, fs, 8, 'morl',plottype);
% Normalized energy for each coefficient
for i= 1:size(w,3)
  x= w(:,:,i);
  x= abs(x.*x);
  w(:,:,i)= 100*x./sum(x(:));
end

f= zeros(size(eeg,1),6); p= zeros(2,2,size(eeg,1)); pwidth= zeros(2,size(eeg,1));
for i= 1:size(w,3)
  x= w(:,:,i);
  x= imgaussfilt(x,wsmooth);  % Smoothen image
  [~,iM]= extrema2(x);       % Find all the local maxima
  p(:,:,i)= selectPeaks(x,iM, 0.2);
  if ~isempty(plottype)
    hold on; plot(t(p(:,1,i)), size(x,1)-p(:,2,i), 'mx'); % Highlight peaks
    hold off;
  end
  pwidth(:,i)= peakWidth(x, p(:,:,i));
  
  f(i,:)= [w(p(1,2,i),p(1,1,i)), pfreq(p(1,2,i)), pwidth(1,i), ...
           w(p(2,2,i),p(2,1,i)), pfreq(p(2,2,i)), pwidth(2,i)];
end

function p= selectPeaks(x, i, promThresh)
% Select the 2 most prominent peaks (the 1st is always the total maximum)

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

function pw= peakWidth(x,peaks)
% Find the width of each peak
pw= peaks(:,1);
% For each peak find the area that is >10% peak height
for p=1:size(peaks,1)
  xp= x(peaks(p,2), peaks(p,1));
  % Select the peak's column from the image
  xu= x(peaks(p,2)+1:end, peaks(p,1));
  xl= x(peaks(p,2)-1:-1:1, peaks(p,1));
  % Cut to 10% peak height
  xu= xu(1 : find(xu < 0.1*xp, 1)-1);
  xl= xl(1 : find(xl < 0.1*xp, 1)-1);
  pw(p)= std([xu;xl]);
end
