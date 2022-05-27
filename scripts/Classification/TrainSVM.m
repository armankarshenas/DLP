%% TrainSVM
% This script implements the Support Vector Machine method

%% Specification 
clc
close all
net = resnet50;
Orien = "AP"; % Specify the orientation you want the script to generate (AP, LR, and DV)
Number_cores = 4; % Specify the number of cores that can be used for SVM training 
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_lab_imgs = "";% Specify the path to top level directory containing all the labelled images in sub-directories 
Path_to_save = "";% Specify the path to directory in which Trained models will be saved
ext = "*." + file_format;
%% Load images
cd(Path_to_lab_imgs)
imds = imageDatastore(orien,'IncludeSubfolders',true,'LabelSource','foldernames');
[imdsTrain,imdsValidation,imdsTest] = splitEachLabel(imds,0.6,0.25,0.15,'randomized');
li = 'avg_pool';
inputSize = net.Layers(1).InputSize;

% Extract features using the convolutional layer of the pre-trained network
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true,'RandXTranslation',pixelRange,'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);
augimdsTest = augmentedImageDatastore(inputSize(1:2),imdsTest,'ColorPreprocessing','gray2rgb');
augimdsVal = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);
Train_f = activations(net,augimdsTrain,li);
Test_f = activations(net,augimdsTest,li);
Val_f = activations(net,augimdsVal,li);

parpool(Number_cores);
Train_f = reshape(Train_f, [size(Train_f,3) size(Train_f,4)]);
options = statset('UseParallel',true);
SVM_model = fitcecoc(Train_f',imdsTrain.Labels,'Verbose',2,'Options',options,'FitPosterior',true);
[label,~,~,posterior] = resubPredict(SVM_model,'verbose',1);
idx = randsample(size(Train_f',1),20,1);
table(imdsTrain.Labels(idx),label(idx),posterior(idx,:),'VariableNames',{'TrueLabel','PredLabel','Posterior'})
[Pred,Score] = predict(SVM_model,reshape(Test_f,[size(Test_f,3) size(Test_f,4)])');
acc = nnz(Pred == imdsTest.Labels)/length(imdsTest.Files);

cd(Path_to_save)
name = "SVM_"+orien+".mat";
save(name,'SVM_model');

