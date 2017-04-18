% a quick test on first finger of first subject, some selection of
% electrodes needs to be done as the speed is very slow

% initialize feature cell array, each cell contains a electrode 
feats=cell(info{1,1}.ch,1);
for i=1:info{1,1}.ch
    feats{i}=extfeat(data{1,1}(:,i),80,40);
end
% create R matrix
R=createR(feats,4,6);
% split data into training and testing sets
train_feat=R(1:4000,:);
test_feat=R(4001:end,:);
% notice that labels are in a resolution of 40 samples, skip first 3 as we
% use 4 previous windows for prediction (include the current one)
train_label=data{2,1}(((1:4000)+3)*40,1);
test_label=data{2,1}(((4001:length(R))+3)*40,1);
% train and test using LASSO
B=lasso(train_feat,train_label);
result=test_feat*B;
c=corr(test_label,result);