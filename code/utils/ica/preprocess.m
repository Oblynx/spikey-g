function eegs= preprocess(eegs)
% eegs= preprocess(eegs)
% Normalize by mean and std, calculate independent components

eegs= (eegs - mean(eegs,2)*ones(1,size(eegs,2))) ./ (std(eegs,0,2)*ones(1,size(eegs,2)));
if ~isnan(eegs)
  x= ica(eegs', size(eegs,1));
  % TODO: low-pass filter to 40 Hz?
  x= filter(ica_filt,x); eegs= x';
end
