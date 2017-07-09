function [models,errors]=enroll(data,testNum,trainNum,ubm,adapt,modelsDir)
%ENROLL Summary of this function goes here
%   Detailed explanation goes here
models=cell(1,size(data,1));
posTestData=[];
%prepearing test and train data and training
for i=1:size(data,1)
    speakerTrainingData=data(i,1:round((trainNum)));
    speakerTestData=data(i,end-round((testNum)):end);
    posTestData=[posTestData;speakerTestData];
    if(adapt)
        gmm= mapAdapt(speakerTrainingData(:),ubm, 10.0, 'mwv');
    else
        gmm = gmm_em(speakerTrainingData(:), 1024, 8, 1, 2);
    end
    models{i}=gmm;
end
%loading previously trained models and thier test data
d=dir(strcat(modelsDir,'/speaker*.mat'));
models1=cell(1,length(d));
for i=1:size(d,1)
    m=load(strcat(modelsDir,'/',d(i).name));
    models1{i}=m.savedVar;
end
models=[models1,models];
posTestDataOld=[];
if(exist('files/posTestData.mat'))
    posTestDataOld=load('files/posTestData.mat');
    posTestDataOld=posTestDataOld.savedVar;
end
posTestData=[posTestDataOld;posTestData];
%resaving the models
d=dir(strcat(modelsDir,'/speaker*.mat'));
len=length(d);
for i=1:length(models)
    matObj1=matfile(strcat(modelsDir,'/speaker',int2str(i),'.mat'),'Writable',true);
    matObj1.savedVar=models{i};
end
%resaving test data
matObj1=matfile('files/posTestData.mat','Writable',true);
matObj1.savedVar=posTestData;
%preparing experment data
%testData for each speaker  is posdata from him 
%and negativeData from all but him
negativeTestData=[];
for i=1:size(posTestData,1)
    temp=[posTestData(1:i-1,:);posTestData(i+1:end,:)];
    negativeTestData=[negativeTestData;temp(:)'];
end
posCount=size(posTestData,2);
negCount=size(negativeTestData,2);
speakersCount=size(posTestData,1);
testData=[posTestData,negativeTestData]';
testData=testData(:);
%labeling the testdata into positive and negative 
labels=[ones(posCount,1);zeros(negCount,1)];
labels=repmat(labels,speakersCount,1);
labels=buffer(labels,posCount+negCount);
%generating trails 
filesIdx=[1:(posCount+negCount)*speakersCount]';
modelIdx=[1:speakersCount];
modelIdx=repmat(modelIdx,posCount+negCount,1);
modelIdx=modelIdx(:);
trails=[modelIdx,filesIdx];
scores = score_gmm_trials(models, testData, trails, ubm);
scores =buffer(scores ,posCount+negCount);
matObj3=matfile('files/ScoresUBM.mat','Writable',true);
matObj3.savedVar=scores;
errors=[];
thresholds=[];
for i=1:speakersCount
     [eer,thres] = compute_eer(scores(:,i),labels(:,i),0);
    errors=[errors,eer];
    thresholds=[thresholds,thres];
end
matObj3=matfile(strcat(modelsDir,'/thres.mat'),'Writable',true);
matObj3.savedVar=thresholds;
matObj3=matfile(strcat(modelsDir,'/eer.mat'),'Writable',true);
matObj3.savedVar=errors;

