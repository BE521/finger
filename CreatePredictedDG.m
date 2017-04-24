% Arjun Shankar, Will Yang, Jiawei Chen
% BE 521 Final Competition
% Create Predicted DG

%% Load the Variables
load('final.mat')
load('BestLambdas.mat')

%% Identify the Bad Channels
% note: bad channels: subject 1, channel 55
BadChannels = cell(1,3);
% bad channels for subject 1
BadChannels{1} = 55;
% bad channels for subject 2
BadChannels{2} = [21,38];
% bad channels for subject 3
BadChannels{3} = NaN;

%% Initialize the Variables
% initialize predicted_dg cell array
predicted_dg=cell(3,1);
% initialize correlation cell
c=cell(3,1);

%% Filter the 60Hz Noise out
% filter out 60Hz noise from the ECoG datasets
for Patient = 1:3
    bsFilt = designfilt('bandstopfir','FilterOrder',20, ...
        'CutoffFrequency1',60,'CutoffFrequency2',61, ...
        'SampleRate',1500);
    data{1,Patient} = filtfilt(bsFilt,data{1,Patient});
    data{3,Patient} = filtfilt(bsFilt,data{1,Patient});
end

%% Loop through each patient
for Patient=1:3
    
    %% Create R Matrix for Patient
    % initialize feature cell array, each cell contains an electrode
    Features=cell(info{1,Patient}.ch,1);
    
    % extract 6 features for all channels
    for i=1:info{1,Patient}.ch
        if i ~= BadChannels{Patient}
            Features{i}=ExtractFeatures(data{1,Patient}(:,i),100,50);
        end
    end
    
    % store the non-empty features in a feature cell array, a
    a = Features(~cellfun('isempty', Features));
    
    % create R2 matrix with 3 windows before and 6 features
    R=CreateR(a,3,6);
    
    %% Self Validation Training and Testing
    % split R2 data into training and testing sets
    train_feat=R(1:4000,:);
    test_feat=R(4001:end,:);
    
    %Downsample the Label Data
    DownsampledLabels=data{2,Patient}(200:50:length(data{2,Patient}),:);
    train_label=DownsampledLabels(1:4000,:);
    test_label=DownsampledLabels(4001:end,:);
    
    for f=1:5
        % train and test using LASSO
        B=lasso(train_feat,train_label(:,f),'Lambda',BestLambdas(Patient,f));
        predicted_label=test_feat*B;
        c{Patient}(f)=corr(test_label(:,f),predicted_label);
    end
    
    %% Create ECoG Testing R Matrix
    %Create an R Matrix for the Testing ECog Data
    % initialize feature cell array, each cell contains an electrode
    feats2=cell(info{1,Patient}.ch,1);
    
    % extract 6 features for all channels
    for i=1:info{1,Patient}.ch
        if i ~= BadChannels{Patient}
            feats2{i}=ExtractFeatures(data{3,Patient}(:,i),100,50);
        end
    end
    
    % store the non-empty features2 in a feature cell array, b
    b = feats2(~cellfun('isempty', feats2));
    
    % create Test R matrix with 3 windows before and 6 features
    TestR=createR2(b,3,6);
    
    %% Predict the Values for predicted_dg
    %For each finger use the optimal lasso lambda to predict the column
    for f=1:5;
        B=lasso(R,DownsampledLabels(:,f),'Lambda',BestLambdas(Patient,f));
        predicted_dg{Patient}(:,f)=TestR*B;
    end
    
    % initialize yy
    yy = zeros(5,147500);
    %Interpolate Predicted Labels
    yy(:,200:end)=spline(200:50:length(data{3,Patient}),predicted_dg{Patient,1}',200:1:147500);
    
    %Optional Plot the data
    % plot(200:50:length(data{3,p}),predicted_dg{p,1}(:,1),'o',200:1:147500,yy(1,:));
    
    %Redefine predicted_dg{p,1} to be the interpolated
    predicted_dg{Patient,1} = yy';
    
end

Correlation=mean(mean(cell2mat(c)));