
function R=createR2(feats,winnum,featnum)
feats2=cell2mat(feats);
R=ones(length(feats{1})-winnum+1,1+winnum*featnum*length(feats));
for n=1:length(feats{1})-winnum+1
    R(n,2:end)=reshape(feats2(:,n:n+winnum-1),1,[]);    
end
