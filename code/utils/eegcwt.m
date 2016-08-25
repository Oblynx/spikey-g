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
for i=1:channels
  % Calc wavelets
  x= eeg(i,:);
  wcf(:,:,i) = cwt(x,scales,mwave);
  % Plot
  if ~isempty(plottype)
    wpfreqgram(plottype, wcf(:,:,i), pfreq, t,x);
  end
end
% Show freq range
%figure; plot(scales,pfreq(i,:))
%fprintf('Scales\t   Freqs\n%.2f\t-> %.2f\n%.2f\t-> %.2f\nl=%d\n', ...
%        scales(1),pfreq(1),scales(end),pfreq(end),length(scales));

