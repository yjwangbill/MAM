function [ ThetaThresh ] = threshTheta( Theta, nu )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
index = nu<0.5;
nu(index)=0;
nu(~index)=1;
[~, ind] = max(Theta,[],1);
%ind=find(Theta==max(Theta,[],1));

[L,P] = size(Theta);
ThetaThresh = zeros(P,L);
for pp=1:P
ThetaThresh(pp,ind(pp))=1*nu(pp);
end




end

