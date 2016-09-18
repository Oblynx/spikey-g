function [f]= extractFeatures(eeg, fs, params, plottype)
% eeg: [channel]x[time] Part of eeg time series from which the characteristics
% of the 2 most prominent wavelet peaks will be extracted

% Remove reference channel
if size(eeg,1) == 257
  eeg= eeg(1:256,:);
end

channelNum= size(eeg,1);
lastfig= get(groot,'CurrentFigure');
if ~isempty(lastfig)
  lastfig= lastfig.Number;
else
  lastfig= 0;
end

t= (0:size(eeg,2))/fs;
[w,pfreq]= eegcwt(eeg, fs, params.voicesPerOct, params.waveMaxFrq, plottype);
% Normalized energy for each coefficient
for channel= 1:channelNum
  if sum(abs(eeg(channel,:))) > 1E-3
    wvt= w(:,:,channel);
    wvt= abs(wvt.*wvt);
    w(:,:,channel)= 100*wvt./sum(wvt(:));
  else
    w(:,:,channel)= NaN;
  end
end

f= zeros(channelNum, 3*params.peaksNum);
peakLog= zeros(params.peaksNum, 2, channelNum);
prominenceUnderflow= 0;
for channel= 1:channelNum
  wvt= w(:,:,channel);
  if ~isnan(wvt(1,1))
    if params.waveSmoothStd > 0
      wvtSmooth= imgaussfilt(wvt,params.waveSmoothStd);  % Smoothen image
    else
      wvtSmooth= wvt;
    end
    
    % Find all the local maxima
    iM= find(imregionalmax(wvtSmooth));
    [~,idxSorted]= sort(wvtSmooth(iM),'descend');
    iM= iM(idxSorted);
    
    % Select the most prominent peaks
    [peaks, underfl]= selectNPeaks(wvtSmooth,iM, params.prominenceThreshold, params.peaksNum);
    prominenceUnderflow= prominenceUnderflow+underfl;
    pwidth= peakWidth(wvtSmooth, peaks);
    
    for peak=1:params.peaksNum
      f(channel, 3*(peak-1)+1 : 3*peak)= ...
          [wvt(peaks(peak,2), peaks(peak,1)), pfreq(peaks(peak,2)), pwidth(peak)];
    end
    
    peakLog(:,:,channel)= peaks;
  else
    f(channel,:)= NaN;
  end
end
if prominenceUnderflow > params.prominenceUnderflowWarningThreshold
  fprintf('[extractFeatures]: WARNING! prominence underflow=%d\n', prominenceUnderflow);
end

% Highlight peaks
if ~isempty(plottype)
  for channel= 1:channelNum
    figure(lastfig + channel);
    hold on;
    for peak= 1:params.peaksNum
      plot(t(peakLog(peak,1,channel)), size(w,1) - peakLog(peak,2,channel), 'rx');
    end
    hold off;
  end
end
end

function [peaks, thresholdUnderflow]= selectNPeaks(image, posLocmax, promThresh, peaksNum)
% Select the N most prominent peaks (the 1st is always the total maximum)
% - peak prominence: how the area of the valley between the 2 peaks
% compares to the median level of the image. 0 means no valley, 1 is a valley
% as deep as the signal median

n= size(image, 1);
prominence= zeros(length(posLocmax),1);
medImg= median(image(:));         % Used as reference level for the image
imgDiag= norm(size(image));
[posLocmax(:,2), posLocmax(:,1)]= ind2sub(size(image), posLocmax);
peaks= zeros(peaksNum,2) - 1;   % init null
peaks(1,:)= posLocmax(1,:);
thresholdUnderflow= 0;

for peak=2:peaksNum
  % Find the largest maximum that is prominent enough
  for ii=2:length(posLocmax)
    % Calculate the line connecting the previous peak with the candidate peak
    xline= peaks(peak-1,1):posLocmax(ii,1);
    if isempty(xline)                             % might have to go in reverse
      xline= peaks(peak-1,1):-1:posLocmax(ii,1);
    end
    yline= round(linspace(peaks(peak-1,2),posLocmax(ii,2), length(xline)));
    idxline= yline+n*(xline-1);    % Linear indices of between-maxima line
    maximline= image(idxline);     % Between-maxima line
    candidate= maximline(end);     % The candidate is by definition at the end of the line

    % Find the candidate's prominence
    valley= sum(candidate - maximline(maximline < candidate));    % = valley * length(maximline)
    reflevel= abs(candidate - medImg) * imgDiag;                  % = (candidate-ref) * diagonal
    prominence(ii)= valley/reflevel;
    % Select if prominent
    if prominence(ii) > promThresh
      peaks(peak,:)= posLocmax(ii,:);
      break;
    end
  end
  if peaks(peak,:) == [-1,-1]                     % if peak is still null
    [~,ii]= min(abs(prominence - promThresh));    % select the best candidate
    peaks(peak,:)= posLocmax(ii,:);
    thresholdUnderflow= thresholdUnderflow+1;
  end
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
