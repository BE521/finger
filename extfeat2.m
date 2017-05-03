% extract features of given data vector
% data - a vector of EEG data from one electrode
% winlen - length of each window
% overlap - overlap length between each window
% return value: a matrix of features, row 1 for the average time-domain
%              voltage, row 2-6 for the average frequency-domain magnitude
%              in five frequency bands, each column stands for a window.

function out=extfeat2(data,winlen,overlap)

% force data to be in row vector
data=reshape(data,1,length(data));
% calculate window number
n=floor((length(data)-overlap)/(winlen-overlap)); 
mvol=zeros(6,n);
dt1=dddtree('cplxdt',data(1:length(data)-mod(length(data),32)),5,'dtf2');
dt2=dddtree('cplxdt',data(end-255:end),5,'dtf2');
for i=1:6
    dtt1=dt1;
    dtt2=dt2;
    for j=1:6
        if j==i; continue; end
        dtt1.cfs{j}=zeros(1,length(dtt1.cfs{j}),2);
        dtt2.cfs{j}=zeros(1,length(dtt2.cfs{j}),2);
    end
    wave(1,:)=[idddtree(dtt1),zeros(1,mod(length(data),32))];
    wave(2,:)=[zeros(1,length(data)-256),idddtree(dtt2)];
    wave=sum(wave)./sum(wave~=0);
    % calculate moving average
    c=conv(wave,ones(1,winlen)/winlen);
    % pick the average every (winlen-overlap) to get window everages
    mvol(i,:)=c((0:n-1)*(winlen-overlap)+winlen);
end

% calculate the spectrogram with given window parameter and get the result
% for each (0-500) Hz.
s=abs(spectrogram(data,winlen,overlap,1e3,1e3));
% calculate the average for each frequency bands and return the result
out=[mvol;mean(s(6:16,:));mean(s(21:26,:));mean(s(76:116,:));mean(s(126:161,:));mean(s(161:176,:))];