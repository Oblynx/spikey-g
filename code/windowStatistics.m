%% windowStatistics
% Load a data file into the eegdata_[no]bul vars
clear; %close all;
d= dir('data/PTES_2/matfilesT1/ptes07*.mat');
load(['data/PTES_2/matfilesT1/',d.name]); clear('d');
eegdata_bul= bul_Averageptes07; eegdata_nbul= nobul_Averageptes07;
eegdata_select= eegdata_bul;

% Parameters + padding, upsampling
upsampling= 1;     % upsampling: Upsample to this many times the original fs
fs= 250*upsampling; t_w=0.05;  % t_w: window length in sec
orders= 8;         % orders: max statistics order (<=8)

L= round(t_w*fs);  % L: window length in samples
eegdata_select= resample(eegdata_select', upsampling,1)';
[C,N]= size(eegdata_select);
eegdata_select= eegdata_select - mean(eegdata_select,2)*ones(1,N); % zero-mean

x= [eegdata_select(:,1)*ones(1,ceil((L-1)/2)), eegdata_select, ...
    eegdata_select(:,end)*ones(1,floor((L-1)/2))]; % pad the signals
time= linspace(0, N/fs, N); % create the time vector for the plots

%% Calculate the statistics
stat= zeros(C,N,orders); % 3rd dim: orders of statistics
%{
% Use the standard functions for low-order moments (can't generalize to higher orders)
for i=1:N
  w= x(:,i:i+L-1);
  stat(:,i,1)= mean(w,2);
  stat(:,i,2)= var(w,0,2);
  stat(:,i,3)= skewness(w,0,2);
  stat(:,i,4)= kurtosis(w,0,2);
end
%}
%
% Use the general moment calculations (generalizes to higher orders)
for i=1:N
  w= x(:,i:i+L-1);
  ws= std(w,0,2);
  for order=2:orders
    if order == 2
      stat(:,i,order)= moment(w,order,2)*L/(L-1);
    else
      stat(:,i,order)= moment(w,order,2)*L/(L-1) ./ ws.^order;
    end
  end
end
%}

%% Plot the results
% Per-channel plots
figure(1);
subplot(221); plot(time, x(:,L:end)); title('sig'); xlabel('t (s)');
subplot(222); plot(time, stat(:,:,2)); title('var'); xlabel('t (s)');
subplot(223); plot(time, stat(:,:,3)); title('skew'); xlabel('t (s)');
subplot(224); plot(time, stat(:,:,4)); title('kurt'); xlabel('t (s)');

% Average from all channels
meanChannelStat= squeeze(mean(stat,1)); 
figure(2);
subplot(221); plot(time, mean(x(:,L:end),1)); title('sig'); xlabel('t (s)');
subplot(222); plot(time, meanChannelStat(:,2)); title('var'); xlabel('t (s)');
subplot(223); plot(time, meanChannelStat(:,3)); title('skew'); xlabel('t (s)');
subplot(224); plot(time, meanChannelStat(:,4)); title('kurt'); xlabel('t (s)');

% Plot the higher orders
if order > 4
  figure(3);
  for i=5:orders
    subplot(2,2,i-4); plot(time, stat(:,:,i)); title(num2str(i));
    xlabel('t (s)');
  end
end
