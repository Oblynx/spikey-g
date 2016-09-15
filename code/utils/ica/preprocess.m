function eegs= preprocess(eegs, params)
% eegs= preprocess(eegs)
% Normalize by mean and std, calculate independent components

eegs= (eegs - mean(eegs,2)*ones(1,size(eegs,2))) ./ (std(eegs,0,2)*ones(1,size(eegs,2)));
if ~isnan(eegs)
  if params.ica
    x= ica(eegs', size(eegs,1));
  end
  if params.ica_filt
    x= filter(ica_filt(params.filtFrq),x); eegs= x';
  end
end
