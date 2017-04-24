%% CreateR This function turns a feature cell array into an R matrix
%
% R = CreateR(Feats,WindowNum,FeatNum)
%
% Feats - cell array of feature matrices from extfeat(), with an electrode in
% each cell
% WindowNum - number of previous windows used for R
% FeatNum - number of features, for compatibility

%%
% Arjun Shankar, Will Yang, Jiawei Chen
% BE 521 Final Competition
% Function to Turn a Feature into an R Matrix

%%
function R=CreateR(Feats,WindowNum,FeatNum)

%Convert the Feature Cell Structure Into a Matrix
Feats2=cell2mat(Feats);

%Initialize the Variable R
R=ones(length(Feats{1})-WindowNum+1,1+WindowNum*FeatNum*length(Feats));

%Redefine the Rows of R with Features
for n=1:length(Feats{1})-WindowNum+1
    R(n,2:end)=reshape(Feats2(:,n:n+WindowNum-1),1,[]);    
end
end
