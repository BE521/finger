% extract features of given data vector
% data - a vector of EEG data from one electrode
% disp - displacement of each window
% return value: a matrix of features, rows for the average frequency-domain magnitude
%               by discrete wavelet transform, each column stands for a window.
function out=newfeats(data,disp)
    %divide into windows
    temp=movwin(data,256,256-disp,1);
    out=zeros(34,length(temp));
    for i=1:length(temp)
        % performs dual-tree wavelet transform
        wt=dddtree('cplxdt',temp(:,i),5,'dtf2');
        c=1;
        %simply average two low frequency bands
        for j=1:2
            out(c,i)=mean(wt.cfs{7-j}(:,:,1).^2);
            out(c+1,i)=mean(wt.cfs{7-j}(:,:,2).^2);
            c=c+2;
        end
        %divide high-frequency bands into smaller one of 16 points
        for j=1:4
            for k=1:2^(j-1)
                out(c,i)=mean(wt.cfs{5-j}((1:16)+(k-1)*16,:,1).^2);
                out(c+1,i)=mean(wt.cfs{5-j}((1:16)+(k-1)*16,:,2).^2);
                c=c+2;
            end
        end
    end