% feats - cell array of feature matrices from extfeat(), with an electrode in
%        each cell
% winnum - number of previous windows used for R
% featnum - number of features, for compatibility

function out=createR(feats,winnum,featnum)
% intialize R
out=zeros(length(feats{1})-winnum+1,featnum*winnum*length(feats));
% loop for each sample
for i=1:length(feats{1})-winnum+1
    % loop for each time window for one sample
    for j=1:length(feats)
        out(i,(1:featnum*winnum)+(j-1)*featnum*winnum)=...
            reshape(feats{j}(1:featnum,(1:winnum)+i-1),1,featnum*winnum);
    end
end
        
    