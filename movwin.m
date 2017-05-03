%%
% data - a vector of original data
% winLen - length of each window
% overlap - overlapped length of each window
% type - 1.left align / 2. middle align / 3. right align
% return value - an matrix of windows, 
function out=movwin(data, winlen, overlap, type)
n=floor((length(data)-overlap)/(winlen-overlap));
switch type
    case 1
        init=0;
    case 2
        init=round((length(data)-(n-1)*(winlen-overlap)-winlen)/2);
    case 3
        init=round(length(data)-(n-1)*(winlen-overlap)-winlen);
end
sample=(0:n-1)*(winlen-overlap)+1+init;
sample=repmat(sample,winlen,1)+repmat(((1:winlen)-1)',1,n);
out=data(sample);