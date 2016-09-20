function [wcf, pfreq, scales, t] = eegcwt(eeg, fs, voicesPerOct, frqLim, padmode, mwave, resamplingFactor, plottype)
% [wcf, pfreq, scales] = eegcwt(eeg, fs, voicesPerOct, maxFrq, plottype)
%   Calculate and show the cwt for each eeg channel. The mother wavelet has to
%   be changed inside the function, because their names are incompatible between
%   the `centfrq` and `cwtft` functions.
%
% eeg: [channel]x[time] Matrix of eeg signals
% fs: sampling frequency
% voicesPerOct: defines the transform's resolution in scales
% frqLim: [2] minimum & maximum frequency to compute transform
% padmode: 'zpd','sp0','sp1','symw','asymw','ppd' (see dwtmode)
% mwave: mother wavelet, only 'morl', 'mexh' supported
% resamplingFactor: if >1, resample (interpolate) eegs with that factor
% plottype: 'image', 'contour' or [] (empty)
%
% wcf: [scales]x[time]x[channel] Matrix of wavelet coefficients
% pfreq: [scales]x1 Pseudofrequencies

% Resample eegs
if resamplingFactor > 1
  eeg= resample(eeg',resamplingFactor,1); eeg= eeg';
  fs= fs*resamplingFactor;
end

% Wavelet params
channels= size(eeg,1);
t= (0:size(eeg,2)-1)/fs;

% Calculate the scales
scales= helperCWTTimeFreqVector(frqLim(1),frqLim(2),centfrq(mwave),1/fs,voicesPerOct);
pfreq= mean([frqLim(1)*scales(end),frqLim(2)*scales(1)])./scales;
wcf= zeros(length(scales),length(t),channels);
% Calc wavelets
for i=1:channels
  wt= cwtft({eeg(i,:),1/fs},'wavelet',mwave,'scales',scales,'padmode',padmode);
  wcf(:,:,i)= real(wt.cfs);
end
% Plot
if ~isempty(plottype)
  for i=1:channels
    wpfreqgram(plottype, wcf(:,:,i), pfreq, t,eeg(i,:));
  end
end

