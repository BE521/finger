% Downsample the EEG data to match the sample rate of the feature data

% EEG - EEG data from one channel
% features - output from the extfeats function

function downsampledEEG = downsample(EEG, features)
    % Figure out the factor to downsample by
    r = floor(numel(EEG)/numel(features(1,:)));
    
    % Use decimate to create a downsampled EEG in which the time points
    % line up with the features
    downsampledEEG = decimate(EEG,r);
end