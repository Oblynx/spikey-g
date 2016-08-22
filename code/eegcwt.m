function [ cfs, pfreq ] = eegcwt(x, fs, voicesPerOct)
% x: 1-channel eeg

% Make sure x is a single channel
xdims= length(size(x));
assert(xdims < 3);
if xdims == 2
  assert(sum(size(x)==1) == 1);
  x= x';
end

% Calc wavelets
t= (0:length(x)-1)/fs;
a0 = 1.67^(1/voicesPerOct);
numoctaves = 10;
scales = 4*a0.^(voicesPerOct:1/voicesPerOct:numoctaves*voicesPerOct);
cfs = cwt(x,scales,'morl');
pfreq = scal2frq(scales,'morl',1/fs);

% Plot & results
wpfreqgram('image', cfs, pfreq, t,x);
%figure; plot(scales,pfreq)
fprintf('Scales\t   Freqs\n%.2f\t-> %.2f\n%.2f\t-> %.2f\nl=%d\n', ...
        scales(1),pfreq(1),scales(end),pfreq(end),length(scales));
end

