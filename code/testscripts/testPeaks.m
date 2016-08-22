N=1000; gn=randn(N,1); gn= gn-mean(gn); a=cumsum(gn);
a= conv(a,ones(5,1)/5,'same');
figure(1);plot(a);

[p,s]= kPeaks(10,a,1);

hold on; scatter(p,a(p),30,'r'); hold off;
