function [models,eer]=enrollment(data,testNum,trainNum,ubm,test,visualize,adapt,modelsDir,add)
%Do the enrollment step to create and store the models and their respective
%thresholds
%Params:
%   -data: cell array with size n*m where n is the number of speakers and m
%       is the number of wav files and each cell contains a matrix of features
%       of the respective file and speaker 
%   -testNum : number of files to be used for testing (thresholds calculation)
%   -trainNum: number of files to be used for training the models
%   -ubm : the pretrained UBM model as a struct 
%   -test : if true do acctual enrollment else just load the previous
%       models and test them on the data 
%   -visualize : just calculate the eer of the pretrained models with the
%       previous data (i.e. discared param data and use the pre calculated scores )
%   -adapt : if true the models would be adapted from the UBM else they
%       would be traind from scratch 
%  -modelsDir: the directory containing the models and where the new data
%       will be saved
%   -add : if false the trained models will replace the previously trained
%       models else it will add them to the previously trained models 
%
%example : 
%   first time :
%   [models,eer]=enrollment(data,50,50,ubm,1,0,1,'models',0)
%   
if(~visualize)
models=cell(1,size(data,1));
posTestData=[];
if(test)
    len=length(dir(strcat(modelsDir,'/*.mat')));
    for i=1:size(data,1)
        speakerTrainingData=data(i,1:round((trainNum)));
        speakerTestData=data(i,end-round((testNum)):end);
        posTestData{i}=speakerTestData;
        if(adapt)
            gmm= mapAdapt(speakerTrainingData(:),ubm, 10.0, 'mwv');
        else
            gmm = gmm_em(speakerTrainingData(:), 1024, 8, 1, 2);
        end
        models{i}=gmm;
    end
    for i=1:size(data,1)
        if(add)
            counter=len+i;
        else
            counter=i;
        end
        matObj1=matfile(strcat(modelsDir,'/speaker',int2str(counter),'.mat'),'Writable',true);
        matObj1.savedVar=models{i};
    end
else
    d=dir(strcat(modelsDir,'/*.mat'));
    models=cell(1,length(d));
    for i=1:size(d,1)
        m=load(strcat(modelsDir,'/',d(i).name,'.mat'));
        models{i}=m.savedVar;
    end
end
if (exist('files/posTestData.mat')==2)
    posTestDataOld=load('files/posTestData.mat');
    posTestDataOld=posTestDataOld.savedVar;
else
    posTestDataOld=[];
end
posTestData=[posTestData;posTestDataOld];
speakersNum=length(models);
p=[];
for i=1:length(posTestData)
    p=[p;posTestData{i}];
end
testData=[];
for i=1:speakersNum-1
temp=[p(1:i-1,:);p(i+1:end,:)];
temp=temp(:);
testData=[testData;temp'];
end
temp=[p(1:end-1,:)];
temp=temp(:);
testData=[testData;temp'];
labels=[ones(1,size(p,2)),zeros(1,size(testData,2))]';
labels=repmat(labels,[speakersNum,1]);
testData=[p,testData]';
trails=[];
trails2=[];
for i=1:speakersNum
    trails=[trails;ones(size(testData,1),1)*i];
    temp=((i-1)*size(testData,1)+[1:size(testData,1)])';
    trails2=[trails2;temp];
end
trails=[trails,trails2];
testData=testData(:);
scores = score_gmm_trials(models, testData, trails, ubm);
matObj3=matfile('files/ScoresUBM.mat','Writable',true);
matObj3.savedVar=scores;
else
scores = load('files/ScoresUBM.mat');
scores=scores.savedVar;
end
modelScoresLength=(size(data,1)-1)*trainNum+trainNum;
eers=[];
thress=[];
for i=1:size(data,1)
    [eer,thres] = compute_eer(scores(1+(i-1)*modelScoresLength:i*modelScoresLength),...
        labels(1+(i-1)*modelScoresLength:i*modelScoresLength), 1);
    eers=[eers,eer];
    thress=[thress,thres];
end
matObj3=matfile(strcat(modelsDir,'/thres.mat'),'Writable',true);
matObj3.savedVar=thress;
matObj3=matfile(strcat(modelsDir,'/eer.mat'),'Writable',true);
matObj3.savedVar=eers;
