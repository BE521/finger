% Arjun Shankar, Will Yang, Jiawei Chen
% BE 521 Final Competition
% Create Predicted DG

%% Load the Variables
load('final.mat')
%load('BestLambdas.mat')
BestLambdas=zeros(5,3);

%% Identify the Bad Channels
% bad channels for each subject:
badChannels ={55,[21,38],50};
% channel selection for each finger and subject
selection = {[1,17,39,43],[8,12,15,24],[9,49,54,56];...
             [1,39,43],[8,38,41],[18,52,54];...
             [1,16,17,38],[3,5,8,24,32],[52,54,18];...
             [1,2,36,39],[22,25,30,33],[41,56];...
             [1,17,33,34,39],[8,22,25,37],[9,41,54]};

%% Initialize the Variables
% initialize predicted_dg cell array
predicted_dg=cell(3,1);
% initialize correlation cell
c=cell(3,1);

%% Common Reference Average (CRA)
for n = 1:3
    data{1,n} = data{1,n}-repmat(mean(data{1,n}(:,setdiff(1:info{1,n}.ch,badChannels{n})),2),1,info{1,n}.ch);
    data{3,n} = data{3,n}-repmat(mean(data{3,n}(:,setdiff(1:info{3,n}.ch,badChannels{n})),2),1,info{3,n}.ch);
end

%% Loop through each patient
for Patient=1:3
   %% Downsample the Label Data
    % downsample to 25Hz, with is consistent with the sample rate of fingers
    DownsampledLabels=data{2,Patient}(220:40:length(data{2,Patient}),:);
    for Finger=1:5
       %% Create R Matrix for Finger
        % initialize feature cell array, each cell contains an electrode
        Features=cell(info{1,Patient}.ch,1);

        % extract 6 features for all channels
        for i=selection{Finger,Patient}
            Features{i}=extfeat(data{1,Patient}(:,i),100,60);
        end

        % store the non-empty features in a feature cell array, a
        a = Features(~cellfun('isempty', Features));

        % create R2 matrix with 4 windows before and 6 features
        R=CreateR(a,4,6);

       %% Create ECoG Testing R Matrix
        %Create an R Matrix for the Testing ECog Data
        % initialize feature cell array, each cell contains an electrode
        feats2=cell(info{3,Patient}.ch,1);

        % extract 6 features for all channels
        for i=selection{Finger,Patient}
            feats2{i}=extfeat(data{3,Patient}(:,i),100,60);
        end

        % store the non-empty features2 in a feature cell array, b
        b = feats2(~cellfun('isempty', feats2));

        % create Test R matrix with 4 windows before and 6 features
        TestR=CreateR(b,4,6);

       %% Predict the Values for predicted_dg
        %For each finger use the optimal lasso lambda to predict the column

        [B,FitInfo]=lasso(R,DownsampledLabels(:,Finger),'CV',10);
        BestLambdas(Finger,Patient)=FitInfo.LambdaMinMSE(1);
        predicted_dg{Patient}(:,Finger)=TestR*B(:,FitInfo.IndexMinMSE(1));

    end
    % initialize yy
    yy = zeros(5,147500);
    %Interpolate Predicted Labels
    yy(:,220:180+length(predicted_dg{Patient})*40)=...
        spline(220:40:147500,predicted_dg{Patient}',220:180+length(predicted_dg{Patient})*40);
    
    %Optional Plot the data
    % plot(200:50:length(data{3,p}),predicted_dg{p,1}(:,1),'o',200:1:147500,yy(1,:));
    
    %Redefine predicted_dg{p,1} to be the interpolated
    predicted_dg{Patient,1} = yy';
    
end