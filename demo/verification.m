function [ decision,score ] = verification( wav,fs,id,modelsDir,ubm)
% verify a wav file against a model 
%params :
%   -wav : wav array 
%   -fs : sampling frequency
%   -id : the model whose identity is claimed 
%   -modelsDir : the dir containg the models 
%   -ubm : the ubm model 
% eg:
% [ decision ,score] = verification( wav,fs,i,'E:\GP\NLP
% project\code\pre-trained models\models',ubm)
if(exist(strcat(modelsDir,'/speaker',int2str(id),'.mat'),'file')==2)
    data=melfcc(wav, fs, 'Deltas',1,'uniformGain',1);
    model=load(strcat(modelsDir,'/speaker',int2str(id),'.mat'));
    model=model.savedVar;
    thres=load(strcat(modelsDir,'/thres.mat'));
    thres=thres.savedVar(id);
    score = score_gmm_trials({model}, {data}, [1,1], ubm);
    if(score>=thres)
        decision=1;
    else
        decision=0;
    end
else
    disp invalid ID 
    exit()
end

end

