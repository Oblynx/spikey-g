function [wcf, pfreq, scales] = eegcwt(eeg, fs, voicesPerOct, maxFrq, plottype)
% [wcf, pfreq, scales] = eegcwt(eeg, fs, voicesPerOct, maxFrq, plottype)
%   Calculate and show the cwt for each eeg channel. The mother wavelet has to
%   be changed inside the function, because their names are incompatible between
%   the `centfrq` and `cwtft` functions.
%
% eeg: [channel]x[time] Matrix of eeg signals
% fs: sampling frequency
% voicesPerOct: defines the transform's resolution in scales
% plottype: 'image', 'contour' or [] (empty)
%
% wcf: [scales]x[time]x[channel] Matrix of wavelet coefficients
% pfreq: [scales]x1 Pseudofrequencies

% Wavelet params
channels= size(eeg,1);
t= (0:size(eeg,2)-1)/fs;

% Calculate the scales
scales= helperCWTTimeFreqVector(0.6,maxFrq,centfrq('morl'),1/fs,voicesPerOct);
pfreq= mean([0.6*scales(end),maxFrq*scales(1)])./scales;
wcf= zeros(length(scales),length(t),channels);
% Calc wavelets
parfor i=1:channels
  wt= cwtft({eeg(i,:),1/fs},'wavelet','morl','scales',scales,'padmode','zpd');
  wcf(:,:,i)= real(wt.cfs);
end
% Plot
if ~isempty(plottype)
  for i=1:channels
    wpfreqgram(plottype, wcf(:,:,i), pfreq, t,eeg(i,:));
  end
end

