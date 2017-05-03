function [predicted_dg] = make_predictions(test_ecog)

%
% Inputs: test_ecog - 3 x 1 cell array containing ECoG for each subject, where test_ecog{i} 
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.
% Outputs: predicted_dg - 3 x 1 cell array, where predicted_dg{i} contains the 
% data_glove prediction for subject i, which is an N x 5 matrix (for
% fingers 1:5)
% Run time: The script has to run less than 1 hour.
%
% The following is a sample script.

% Arjun Shankar, Will Yang, Jiawei Chen
% BE 521 Final Competition
% Create Predicted DG

%% Load the Variables
load('param.mat')

%% Initialize the Variables
% initialize predicted_dg cell array
predicted_dg=cell(3,1);

%% Common Reference Average (CRA)
for n = 1:3
    test_ecog{n} = test_ecog{n}-repmat(mean(test_ecog{n}(:,setdiff(1:size(test_ecog{n},2),badChannels{n})),2),1,size(test_ecog{n},2));
end

%% Loop through each patient
for Patient=1:3
    %% Extract features
        % extract features for all channels with discrete wavelet
        % transform
        feats=cell(size(test_ecog{Patient},2),1);
        for i=unique(cell2mat({selection{:,Patient}}))
            disp(['extracting p' int2str(Patient) 'ch' int2str(i)])
            feats{i}=[newfeats(test_ecog{Patient}(:,i),40);extfeat2(test_ecog{Patient}(:,i),256,216)];
        end
    
    for Finger=1:5
       %% Create R
        a = {feats{selection{Finger,Patient}}}';
        R = CreateR(a,4,size(a{1,1},1));

       %% Predict the Values for predicted_dg
        %For each finger use the optimal lasso lambda to predict the column

       %for selecting lambda
       disp(['predicting p' int2str(Patient) 'f' int2str(Finger)])
       predicted_dg{Patient}(:,Finger)=R(:,featsel{Finger,Patient})*Bs{Finger,Patient};
               
        

    end
    % initialize yy
    yy = zeros(5,size(test_ecog{n},1));
    %Interpolate Predicted Labels
    yy(:,376:336+length(predicted_dg{Patient})*40)=...
        spline(376:40:336+length(predicted_dg{Patient})*40,predicted_dg{Patient}',376:336+length(predicted_dg{Patient})*40);
    
    %Redefine predicted_dg{p,1} to be the interpolated
    predicted_dg{Patient} = yy';
    
end

