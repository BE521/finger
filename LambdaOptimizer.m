% Arjun Shankar, Will Yang, Jiawei Chen
% BE 521 Final Competition
% Code to Optimize Lambdas

%% Load the Variables
load('final.mat')

%% Identify the Bad Channels
% Note: bad channels: subject 1, channel 55
BadChannels = cell(1,3);
% Bad channels for subject 1
BadChannels{1} = 55;
% Bad channels for subject 2
BadChannels{2} = [21,38];
% Bad channels for subject 3
BadChannels{3} = NaN;

%% Calculate the Best Lambdas for Each Respective Person/Finger

% Loop Through Each Patient
for Patient=1:3;
    
    % Initialize feature cell array, each cell contains an electrode
    Features=cell(info{1,Patient}.ch,1);
    
    % Extract 6 features for all channels
    for Channel=1:info{1,Patient}.ch
        if Channel~=BadChannels{Patient}
            Features{Channel}=extfeat(data{1,Patient}(:,Channel),100,50);
        end
    end
    
    % Store the non-empty features in a feature cell array, a
    a=Features(~cellfun('isempty', Features));
    
    % Create an R matrix with 3 windows before and 6 features
    R=CreateR(a,3,6);
    
    % Split R2 data into training and testing sets
    TrainFeats=R(1:4000,:);
    TestFeats=R(4001:end,:);
    
    % Downsample the Label Data
    DownsampledLabels=data{2,Patient}(200:50:length(data{2,Patient}),:);
    TrainLabels=DownsampledLabels(1:4000,:);
    TestLabels=DownsampledLabels(4001:end,:);
    
    %Loop Through each Finger
    for Finger=1:5
        
        %Calculate the Lasso Predictions for 100 lambda values
        [B,FitInfo]=lasso(TrainFeats,TrainLabels(:,Finger));
        PredictedLabels=TestFeats*B;
        
        %Find the Lambda Value that results in the highest correlation
        Correlation=corr(TestLabels,PredictedLabels);
        [MaxValue,MaxLambda]=max(Correlation(Finger,:));
        
        %Add the Lambda Value to its designated spot in the Best Lambdas
        %Matrix. Print it because this code takes long to execute and you
        %can monitor progress this way.
        BestLambdas(Patient,Finger)=FitInfo.Lambda(MaxLambda)
    end
    
end