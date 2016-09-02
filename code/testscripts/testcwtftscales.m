close all;
t= (0:601)/1.6; a= [sin(2*pi*0.1*(0:300)/1.6), sin(2*pi*0.2*(0:300)/1.6)];
figure; subplot(211); plot(t,a); subplot(212); plot(linspace(-0.8,0.8,602),fftshift(abs(fft(a))));
%s0=1.25 ds=0.4875 nb=19
scstr= struct('s0',1.25,'ds',0.2,'nb',32,'type','pow','pow',2);
wstr= cwtft(a,'wavelet','morl', 'scales',scstr,'plot'); sc= wstr.scales; w= wstr.cfs;
pf= scal2frq(sc,'morl',1/1.6);
figure; imagesc(t,flip(pf),fliplr(abs(w)));
