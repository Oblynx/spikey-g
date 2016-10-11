function [f]= extractFeatures(eeg, tWin, fs, params)
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

[w,pfreq,~,t]= eegcwt(eeg, fs, params.voicesPerOct, params.waveFrq, params.padmode, ...
                      params.mwave, params.resamplingFactor, []);

  %w= mean(w,3); % #!!!!@  DANGER  @!!!!# %

w= w(:,tWin,:); t= t(tWin);

channelNum= size(w,3);
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
    peaks= selectNPeaks(wvtSmooth,iM, params.peaksNum);
    pwidth= peakWidth(wvtSmooth, peaks);
    
    for peak=1:params.peaksNum
      f(channel, 3*(peak-1)+1 : 3*peak)= ...
          [wvt(peaks(peak,2), peaks(peak,1)), log2(pfreq(peaks(peak,2))), pwidth(peak)];
    end
    
    peakLog(:,:,channel)= peaks;
  else
    f(channel,:)= NaN;
  end
end

% Plot wavelets & highlight peaks
if params.wavePlot
  figure;
  pause on;
  for channel= 1:channelNum
    surf(t,pfreq,w(:,:,channel),'FaceColor','interp','FaceLighting','gouraud', 'MeshStyle','row');
    xlabel('t(s)'); ylabel('f(Hz)'); title('Wavelet energy');
    view(-20,120); material dull;
    light('Position',[0.06 40 0.06],'Style','local');
    light('Position',[0.06 -5 0.06],'Style','local');
    %light('Position',[-0.04 20 0.06],'Style','local');
    %light('Position',[0.15 20 0.06],'Style','local');
    hold on;
    for peak= 1:params.peaksNum
      p= peakLog(peak,:,channel);
      %plot(t(peakLog(peak,1,channel)), size(w,1) - peakLog(peak,2,channel), 'rx');
      plot3(t(p(1)), pfreq(p(2)), w(p(2),p(1),channel)*1.01, 'kh', 'MarkerSize',8, 'MarkerFaceColor','r');
    end
    hold off;
    pause;
  end
  pause off;
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
