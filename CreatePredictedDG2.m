% this code produces the 3 by 1 cell array predicted_dg, where
% predicted_dg{i} corresponds to the predictions for subject i. thus
% predicted_dg{1} is a 147,500x5 dimensional matrix for subject 1.

load('final.mat')
% note: bad channels: subject 1, channel 55
badChannels = cell(1,3);
% bad channels for subject 1
badChannels{1} = 55;
% bad channels for subject 2
badChannels{2} = [21,38];
% bad channels for subject 3
badChannels{3} = NaN;

% initialize predicted_dg cell array
predicted_dg=cell(3,1);

% initialize yy
yy = zeros(5,147500);

% filter out 60Hz noise from the ECoG datasets
for n = 1:3
    bsFilt = designfilt('bandstopfir','FilterOrder',20, ...
         'CutoffFrequency1',60,'CutoffFrequency2',61, ...
         'SampleRate',1500);
    data{1,n} = filtfilt(bsFilt,data{1,n});
    data{3,n} = filtfilt(bsFilt,data{3,n});
end
% initialize correlation cell
c=cell(3,1);
for p=1:3
% initialize feature cell array, each cell contains an electrode 
feats=cell(info{1,p}.ch,1);

% extract 6 features for all channels
for i=1:info{1,p}.ch
    if i ~= badChannels{p}
        feats{i}=extfeat(data{1,p}(:,i),100,50);
    end
end

% store the non-empty features in a feature cell array, a
a = feats(~cellfun('isempty', feats));

% create R2 matrix with 3 windows before and 6 features
R2=createR2(a,3,6);

% split R2 data into training and testing sets
train_feat=R2(1:4000,:);
test_feat=R2(4001:end,:);

%Get label Data downsampled
DownsampledLabels=data{2,p}(200:50:length(data{2,p}),:);
train_label=DownsampledLabels(1:4000,:);
test_label=DownsampledLabels(4001:end,:);

%Calculate f weights
f=(train_feat'*train_feat)\(train_feat'*train_label);

%Predict Labels for Test Set
predicted_label=test_feat*f;

%Calculate Correlation
c{p,1}=corr(test_label,predicted_label);

%Calculate f weights using entire R2 data set
f=(R2'*R2)\(R2'*DownsampledLabels);

%Create an R Matrix for the Testing ECog Data
% initialize feature cell array, each cell contains an electrode 
feats2=cell(info{1,p}.ch,1);

% extract 6 features for all channels
for i=1:info{1,p}.ch
    if i ~= badChannels{p}
        feats2{i}=extfeat(data{3,p}(:,i),100,50);
    end
end

% store the non-empty features2 in a feature cell array, b
b = feats2(~cellfun('isempty', feats2));

% create Test R matrix with 3 windows before and 6 features
TestR=createR2(b,3,6);

%Predict Labels
predicted_dg{p,1}=TestR*f;

%Interpolate Labels, pad yy to make it length 147,500
yy(:,200:end)=spline(200:50:length(data{3,p}),predicted_dg{p,1}',200:1:147500);

% plot(200:50:length(data{3,p}),predicted_dg{p,1}(:,1),'o',200:1:147500,yy(1,:));

%Redefine predicted_dg{p,1} to be the interpolated
predicted_dg{p,1} = yy;
end



