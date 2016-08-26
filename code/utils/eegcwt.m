function [wcf, pfreq, scales] = eegcwt(eeg, fs, voicesPerOct, mwave, plottype)
% eegcwt Calculate and show the cwt for each eeg channel
% eeg: [channel]x[time] Matrix of eeg signals
% fs: sampling frequency
% voicesPerOct: defines the transform's resolution in scales
% mwave: mother wavelet name (eg 'morl')
% plottype: 'image', 'contour' or [] (empty)

% wcf: [scales]x[time]x[channel] Matrix of wavelet coefficients
% pfreq: Pseudofrequencies

% Wavelet params
channels= size(eeg,1);
t= (0:size(eeg,2)-1)/fs;
a0 = 1.67^(1/voicesPerOct);
numoctaves = 10;
scales = 4*a0.^(voicesPerOct:1/voicesPerOct:numoctaves*voicesPerOct);
pfreq = scal2frq(scales,mwave,1/fs);
wcf= zeros(length(scales),length(t),channels);
parfor i=1:channels
  % Calc wavelets
  wcf(:,:,i) = cwt(eeg(i,:),scales,mwave);
end
% Plot
if ~isempty(plottype)
  for i=1:channels
    wpfreqgram(plottype, wcf(:,:,i), pfreq, t,eeg(i,:));
  end
end
% Show freq range
%figure; plot(scales,pfreq(i,:))
%fprintf('Scales\t   Freqs\n%.2f\t-> %.2f\n%.2f\t-> %.2f\nl=%d\n', ...
%        scales(1),pfreq(1),scales(end),pfreq(end),length(scales));

