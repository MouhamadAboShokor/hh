function [ newInput] = PCASmall(varitationRetaind,mat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(~(varitationRetaind<1))
    errorMessage=sprintf('Error:The varitation ratio is invalid choose a ratio between 0.01 and 0.99:\n');
    uiwait(warndlg(errorMessage));
    return;
end;
if(~(varitationRetaind>0))
    errorMessage=sprintf('Error:The varitation ratio is invalid choose a ratio between 0.01 and 0.99:\n');
    uiwait(warndlg(errorMessage));
    return;
end;
%data preprocessing 
%finding the means , the maximum and the minimum of the features in order
%to normalize them
matSize=size(mat);
means=zeros(matSize(1),1);
normalizer=zeros(matSize(1),1);
for i=1:matSize(1)
    means(i)= mean(mat(i,:));
    %beware here if the max=min you will be dividing on zero
    normalizer(i)=max(mat(i,:))-min(mat(i,:));
end;
%now by subtracting the mat from the mean we get mean normalized for all
%the matrix 
for i=1:matSize(2)
    mat(:,i)=mat(:,i)-means;
    mat(:,i)=mat(:,i).*normalizer;
end;
% mat=mat-means;
% mat=mat.*normalizer;
%calculating the covariance matrix 
sigma=(1/matSize(1))*(mat)*mat';
%getting the eigen vectors of the covariance matrix 
[U,S,~]=svd(sigma);
%calculating the approperiat K value where K is the best deminsion to witch
%we will reduce our data while preseving the variation of the data
K=1;
%calculating the sum of the main diagonal in the S matrix 
denomenater=0;
SSize=size(S);
for i=1:SSize(1)
    for j=1:SSize(2)
        if(i==j)
            denomenater=denomenater+S(i,j);
        end;
    end;
end;
%giving the nomenater the value of S when K=1
nominater=S(1,1);
while(((nominater/denomenater)<varitationRetaind))
    K=K+1;
    nominater=0;
    for i=1:K
        for j=1:K 
            if(j==i)
                nominater=nominater+S(i,j);                
            end;
        end;
    end;
end;
%and finally calculating the reduced Input
reducer=U(:,1:K);
newInput=reducer'*mat;
% newInput=newInput';
    %calculating the minmum of the lengths of the examples 
%     min=length(mat(:,1));
%     for i=1:length(mat(1,:))
%         if(min>length(mat(:,i)))
%             min=length(mat(:,i));
%         end;
%     end;
    %unifying the lengths to the minimum using small
%     newInput=[];
%     for i=1:length(mat(1,:))
%         newInput=[newInput small(mat(:,i))];
%     end;
end

