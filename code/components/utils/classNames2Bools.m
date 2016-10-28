function labels= classNames2Bools(labels)
% Convert cell array of class labels {'bul', 'nobul', ...} to bool array
% where 'bul'=1, 'nobul'=0: [1, 0, ...]
labels= cellfun(@class2val, labels) == 1;
end

function v= class2val(x)
if strcmp(x,'bul')
  v= 1;
else
  v= 0;
end
end
