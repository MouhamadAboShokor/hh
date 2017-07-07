function [ out ] = small( mat , s )
%small reduces the input vector to size 's'
%   Detailed explanation goes here
out=[];
step=floor(size(mat,1)/s);
for i=1:s
    out=[out ; mean(mat((i-1)*step+1:i*step,1))];
end;
end