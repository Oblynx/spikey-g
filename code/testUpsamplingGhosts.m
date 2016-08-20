%% Test if upsampling produces ghost images
% Params
T= 100; f=1; fs=4;
upsample= 2;

% Make sig
time= linspace(0, T/f, fs*T/f+1); time= time(1:end-1);
x= sin(2*pi*f*time);
% fft
freq= linspace(-fs/2,fs/2, fs*T/f+1); freq= freq(1:end-1);
X= fft(x);
Xp= fftshift(abs(X));
% Plot
figure(1);
subplot(211); plot(time,x); title('t'); xlabel('t (s)'); axis tight;
subplot(212); plot(freq,Xp); title('f'); xlabel('f (hz)'); axis tight;

%% Upsample
fs= fs*upsample;
time= linspace(0, T/f, fs*T/f+1); time= time(1:end-1);
xu= resample(x, upsample,1);
% fft
freq= linspace(-fs/2,fs/2, fs*T/f+1); freq= freq(1:end-1);
Xu= fft(xu);
Xup= fftshift(abs(Xu));
% plot
figure(2);
subplot(211); plot(time,xu); title('tu'); xlabel('t (s)'); axis tight;
subplot(212); plot(freq,Xup); title('fu'); xlabel('f (hz)'); axis tight;
