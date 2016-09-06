clear; close all;
fs= 3;
t= (0:601)/fs; a= [sin(2*pi*0.2*(0:300)/fs), sin(2*pi*0.5*(0:300)/fs)];
a(100:200)= a(100:200)+ cos(2*pi*0.7*(0:100)/fs);
%a(301)= a(301)+1;
a(246:247)= a(146:147)+0.8; a(402:405)= a(402:405)+0.8;
a= a+0.05*randn(size(a));
figure; subplot(211); plot(t,a); subplot(212); plot(linspace(-fs/2,fs/2,602),fftshift(abs(fft(a))));

s0=0.3; oct=7;voic=32; a0=2^(1/voic);scstr=s0.*a0.^(0:oct*voic);
wstr= cwtft({a,1/fs},'wavelet','morl','scales',scstr,'padmode','sp0'); sc= wstr.scales; w= wstr.cfs;
%pf= scal2frq(sc,'morl',1/fs);
%figure; imagesc(t,flip(pf),fliplr(abs(w)));
figure;wscalogram('image',w,'scales',sc);

%s0=0.003;oct=18;voic=12; a0= 2^(1/voic);sc=s0.*a0.^(0:oct*voic);
%wt=cwtft({eeg,1/250},'scales',sc,'wavelet','morl');wscalogram('image',wt.cfs,'scales',sc);


%% From example with helper funcs
% Reconstruction provides a very close approximation to the input signal
sc= helperCWTTimeFreqVector(0.3,65,centfrq('morl'),1/fs,8);
wt= cwtft({eeg,1/fs},'wavelet','morl','scales',sc,'padmode','zpd','plot');
