function peaks= selectNPeaks(image, posLocmax, peaksNum)
% Select the N most prominent peaks (the 1st is always the total maximum)
% - peak prominence: how the area of the valley between the 2 peaks
% compares to the peak

if length(posLocmax) < peaksNum
  fprintf('[selectNPeaks]: WARNING: fewer local maxima than requested peaks!\n');
end

n= size(image, 1);
[posLocmax(:,2), posLocmax(:,1)]= ind2sub(size(image), posLocmax);
peaks= zeros(peaksNum,2) - 1;   % init null
peaks(1,:)= posLocmax(1,:);

for peak=2:peaksNum
  prominence= zeros(length(posLocmax),1);
  % Find the largest maximum that is prominent enough
  for ii=2:length(posLocmax)
    % local maxima are being removed upon selection
    if posLocmax(ii,1) == -1, continue; end
    % Calculate the line connecting the previous peak with the candidate peak
    xline= peaks(peak-1,1):posLocmax(ii,1);
    if isempty(xline)                             % might have to go in reverse
      xline= peaks(peak-1,1):-1:posLocmax(ii,1);
    end
    % Reject candidates less than 4 points away
    if length(xline) <= 3
      prominence(ii)= 0;
    else
      yline= round(linspace(peaks(peak-1,2),posLocmax(ii,2), length(xline)));
      idxline= yline+n*(xline-1);    % Linear indices of between-maxima line
      maximline= image(idxline);     % Between-maxima line
      candidate= maximline(end);     % The candidate is by definition at the end of the line

      prominence(ii)= candidate - min(maximline);
    end
  end
  % Simply go through all local maxima and select the most prominent
  [~,ii]= max(prominence);
  peaks(peak,:)= posLocmax(ii,:);
  posLocmax(ii,:)= -1;              % annul this local maximum
end
end

