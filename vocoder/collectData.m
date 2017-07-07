function [fullInput,fullOutput]=collectData(dataLocation,trainSetRatio)
if(~((trainSetRatio<1)&&(trainSetRatio>0)))
    errorMessage=sprintf('Error:The training set ratio is invalid:\n%s',dataLocation);
    uiwait(warndlg(errorMessage));
    return;
end;
if(~isdir(dataLocation))
    errorMessage=sprintf('Error:The following folder does not exixts:\n%s',dataLocation);
    uiwait(warndlg(errorMessage));
    return;
end;
emotionsDir=dir(dataLocation);
input=[];
output=[];
lengths=[];
minCepestraLength=1000000000;
for i=1:length(emotionsDir)
    dirFullName=fullfile(dataLocation,emotionsDir(i).name);
    filePattern=fullfile(dirFullName,'*.wav');
    wavFiles=dir(filePattern);
    for k=1:length(wavFiles)
        baseFileName=wavFiles(k).name;
        fullFileName=fullfile(dirFullName,baseFileName);
        samples=wavread(fullFileName);
        cepstra = melfcc(samples);
        %this work same as reshape to convert the matrix to a vector
        cepstra=cepstra(:);
        lengths=[lengths length(cepstra)];
        
        %adjusted for pca small in case you want to roll back
        %input=[input small(cepstra,100)];
        %%%%%%%%%%%%%%%%%%%%%%
        %the adjusments%%%%%%%%%
        %when the loop is over we will get a matrix of unified lengths
        if(length(cepstra)<minCepestraLength)
            minCepestraLength=length(cepstra);
            newInput=[];
            inputSize=size(input);
            for l=1:inputSize(2)
                newInput=[newInput small(input(:,l),minCepestraLength)];
            end;
            input=newInput;
        end;
        input=[input small(cepstra,minCepestraLength)];
        %%%%%%%%%%%%%%%%%%%%%%
        nameCode=decodeName(baseFileName);
        output=[output nameCode'];
    end;
end;
input=PCASmall(0.99,input);
%now since that the number of features is nearly 202 which is much close to
%the number of examples we copy the same examples few times 
inputSize=size(input);
fullInput=[];
fullOutput=[];
fullInputSize=size(fullInput);
while(fullInputSize<10*inputSize)
    fullInput=[fullInput input];
    fullOutput=[fullOutput output];
    fullInputSize=size(fullInput);
end
% outputSize=size(output);
% inputTrain=input(:,1:ceil(inputSize(2)*trainSetRatio));
% inputTest=input(:,ceil(inputSize(2)*trainSetRatio):inputSize(2));
% outputTrain=output(:,1:ceil(outputSize(2)*trainSetRatio));
% outputTest=output(:,ceil(outputSize(2)*trainSetRatio):inputSize(2));
end

