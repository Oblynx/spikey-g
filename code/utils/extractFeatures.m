function [f]= extractFeatures(eeg, fs, wsmooth, plottype)
% eeg: [channel]x[time] Part of eeg time series from which the characteristics
% of the 2 most prominent wavelet peaks will be extracted

% Remove reference channel
if size(eeg,1) == 257
  eeg= eeg(1:256,:);
end

lastfig= get(groot,'CurrentFigure');
if ~isempty(lastfig)
  lastfig= lastfig.Number;
else
  lastfig= 0;
end

t= (0:size(eeg,2))/fs;
[w,pfreq]= eegcwt(eeg, fs, 8, 'morl',plottype);
% Normalized energy for each coefficient
for i= 1:size(w,3)
  x= w(:,:,i);
  x= abs(x.*x);
  w(:,:,i)= 100*x./sum(x(:));
end

f= zeros(size(eeg,1),6);
px1= zeros(size(eeg,1)); px2= px1; py1= px1; py2= px1;
parfor i= 1:size(w,3)
  x= w(:,:,i);
  xsm= imgaussfilt(x,wsmooth);  % Smoothen image
  [~,iM]= extrema2(xsm);       % Find all the local maxima
  p= selectPeaks(xsm,iM, 0.2);
  px1(i)= p(1,1); px2(i)= p(2,1);
  py1(i)= p(1,2); py2(i)= p(2,2);
  pwidth= peakWidth(xsm, [px1(i),py1(i);px2(i),py2(i)]);
  
  f(i,:)= [x(py1(i),px1(i)), pfreq(py1(i)), pwidth(1), ...
           x(py2(i),px2(i)), pfreq(py2(i)), pwidth(2)];
end
if ~isempty(plottype)
  for i= 1:size(w,3)
    figure(lastfig + i);
    hold on; plot(t([px1(i),px2(i)]), size(w,1)-[py1(i),py2(i)], 'rx'); % Highlight peaks
    hold off;
  end
end
end

function p= selectPeaks(x, i, promThresh)
% Select the 2 most prominent peaks (the 1st is always the total maximum)

prominence= zeros(length(i),1);
medx= median(x(:));
[i(:,2), i(:,1)]= ind2sub(size(x), i);
p(1,:)= i(1,:);
p(2,:)= [0,0];
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
  prominence(ii)= (candidate-min(x(ir)))/(candidate-medx);
  if prominence(ii) > promThresh
    p(2,:)= i(ii,:);
    break;
  end
end
if p(2,:)==[0,0]
  [~,ii]= min(abs(prominence - promThresh));
  p(2,:)= i(ii,:);
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
end
