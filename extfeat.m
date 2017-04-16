% extract features of given data vector
% data - a vector of EEG data from one electrode
% winlen - length of each window
% overlap - overlap length between each window
% return value: a matrix of features, row 1 for the average time-domain
%              voltage, row 2-6 for the average frequency-domain magnitude
%              in five frequency bands, each column stands for a window.

function out=extfeat(data,winlen,overlap)

% calculate window number
n=floor((length(data)-overlap)/(winlen-overlap));
% calculate moving average
c=conv(data,ones(1,winlen)/winlen);
% pick the average every (winlen-overlap) to get window everages
mvol=c((0:n-1)*(winlen-overlap)+winlen);

% calculate the spectrogram with given window parameter and get the result
% for each (0-500) Hz.
s=log10(abs(spectrogram(data,winlen,overlap,1e3,1e3)));
% calculate the average for each frequency bands and return the result
out=[mvol;mean(s(6:16,:));mean(s(21:26,:));mean(s(76:116,:));mean(s(126:161,:));mean(s(161:176,:))];