%%
% data - a vector of original data
% winLen - length of each window
% winDisp - overlapped length of each window
% type - 1.left align / 2. middle align / 3. right align
% return value - an matrix of windows, 
function out=winfeat(data, winLen, winDisp, type)
n=floor((length(data)-winLen)/winDisp+1);
switch type
    case 1
        init=0;
    case 2
        init=round((length(data)-(n-1)*winDisp-winLen)/2);
    case 3
        init=round(length(data)-(n-1)*winDisp-winLen);
end
sample=(1:winDisp:1+(n-1)*winDisp)+init;
sample=repmat(sample,winLen,1)+repmat(((1:winLen)-1)',1,n);
out=data(sample);