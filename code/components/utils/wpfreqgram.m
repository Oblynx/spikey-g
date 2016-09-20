function wpfreqgram(plottype, cfs, pfreq, t,x)
% Plot a cwt with a pseudofrequency axis instead of scales

figure; % go figure...
sc = wscalogram(plottype,flipud(cfs),'scales', ...
                fliplr(round(pfreq,2)),'xdata',t,'ydata',x);
xlabel('t (s)'); ylabel('pfreq (Hz)'); grid minor;
title('Pseudofrequency wavelet graph');
%{
imagesc(t,[],sc); axis fill; grid minor;
title('Pseudofrequency wavelet graph');
colorbar;
indices = get(gca,'ytick');
set(gca,'yticklabel',round(pfreq(indices),2));
numTicks = 8;
L = get(gca,'YLim');
set(gca,'YTick',linspace(L(1),L(2),numTicks))
xlabel('t (s)'); ylabel('pfreq (Hz)');
%}
