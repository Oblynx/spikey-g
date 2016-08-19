%% windowStatistics
fs= 250; t_w=0.1; % window length in sec
L= round(t_w*fs);  % window length in samples

[C,N]= size(bul_Averageptes07);
x= [zeros(C,L-1), bul_Averageptes07-mean(bul_Averageptes07,2)*ones(1,N)]; % zero-pad the signals
time= linspace(0, N/fs, N);

orders= 4;
stat= zeros(C,N,orders); % 3rd dim: orders of statistics
%{
for i=1:N
  w= x(:,i:i+L-1);
  stat(:,i,1)= mean(w,2);
  stat(:,i,2)= std(w,2);
  stat(:,i,3)= skewness(w,1,2);
  stat(:,i,4)= mean(w,1,2);
end
%}
for i=1:N
  w= x(:,i:i+L-1);
  for order=2:orders
    stat(:,i,order)= moment(w,order,2);
  end
end

figure(1);
subplot(221); plot(time, x(:,L:end)); title('sig');
subplot(222); plot(time, stat(:,:,2)); title('var');
subplot(223); plot(time, stat(:,:,3)); title('skew');
subplot(224); plot(time, stat(:,:,4)); title('kurt');

meanChannelStat= squeeze(mean(stat,1)); 
figure(2);
subplot(221); plot(time, mean(x(:,L:end),1)); title('sig');
subplot(222); plot(time, meanChannelStat(:,2)); title('var');
subplot(223); plot(time, meanChannelStat(:,3)); title('skew');
subplot(224); plot(time, meanChannelStat(:,4)); title('kurt');

% HOS
%{
figure(3);
for i=5:orders
  subplot(2,2,i-4); plot(time, meanChannelStat(:,i)); title(num2str(i));
end
%}
