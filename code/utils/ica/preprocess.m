function eegs= preprocess(eegs)

eegs= eegs - mean(eegs,2)*ones(1,size(eegs,2));
eegs= eegs ./ (std(eegs,0,2)*ones(1,size(eegs,2)));
if ~isnan(eegs)
  x= ica(eegs', size(eegs,1)); eegs= x';
  %x= whiten(eegs'); eegs= x';
end
