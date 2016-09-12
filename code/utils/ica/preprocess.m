function eegs= preprocess(eegs)
% eegs= preprocess(eegs)
% Normalize by mean and std, calculate independent components

eegs= (eegs - mean(eegs,2)*ones(1,size(eegs,2))) ./ (std(eegs,0,2)*ones(1,size(eegs,2)));
if ~isnan(eegs)
  x= ica(eegs', size(eegs,1)); eegs= x';
  % TODO: low-pass filter to 40 Hz?
end
