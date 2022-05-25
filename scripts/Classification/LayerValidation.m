%% Layer validation 
%This script trains a deep learning algorithm based on Transfer Learning
%and optimises the layer from which the feature space is generated. 

%% Specification
clear
clc
close all
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to top level directory of the sample data containing all the sub-directories labelled manually 
Path_to_save = "";% Specify the path to directory in which trained models will be saved
addpath(genpath(pwd))

%% Validation 
fprintf("Loading the networks...\n");
net = resnet50;
Layer = net.Layers;
inputSize = net.Layers(1).InputSize;

fprintf("Loading the ref image datasets ... \n");
cd(Path_to_data)
imds = imageDatastore(pwd,'IncludeSubfolders',true,'LabelSource','foldernames');
[imdsTrain,imdsValidation,imdsTest] = splitEachLabel(imds,0.6,0.25,0.15,'randomized');
acc=[];
counter = 1;
%% Training A Fully connected layer
for l=1: length(Layer)
    if contains(Layer(l).Name,"act")
        li = Layer(l).Name;
        name = "resnet50"+"_"+li+".mat";
        fprintf("Getting activations ...\n");
        
        % Extract features using the convolutional layer of the pre-trained network
        pixelRange = [-30 30];
        imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true,'RandXTranslation',pixelRange,'RandYTranslation',pixelRange);
        augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);
        augimdsTest = augmentedImageDatastore(inputSize(1:2),imdsTest,'ColorPreprocessing','gray2rgb');
        augimdsVal = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);
        Train_f = activations(net,augimdsTrain,li);
        Test_f = activations(net,augimdsTest,li);
        Val_f = activations(net,augimdsVal,li);
        clear augimdsTrain
        clear augimdsTest
        clear augimdsVal
        % Layers for the new network
        layer = [
            imageInputLayer([size(Train_f,1) size(Train_f,2) size(Train_f,3)])
            fullyConnectedLayer(length(imds.Labels))
            softmaxLayer()
            classificationLayer()
            ];
        
        % Options used for optimisation
        options = trainingOptions('adam', ...
            'MaxEpochs',400, ...
            'ValidationData',{Val_f imdsValidation.Labels}, ...
            'ValidationFrequency',5, ...
            'Shuffle','every-epoch', ...
            'ValidationPatience',5, ...
            'Plots','none', ...
            'LearnRateDropFactor',0.95, ...
            'LearnRateSchedule','piecewise',...
            'InitialLearnRate',1e-3);
        % Train the network
        fprintf("Training the network ...\n");
        New_net = trainNetwork(Train_f,imdsTrain.Labels,layer,options);
        clear Train_f
        clear Val_f
        
        % Test the network on the labelled data
        [preds,prb] = classify(New_net,Test_f);
        acc(counter) = nnz(preds == imdsTest.Labels)/length(imdsTest.Files);
        clear Test_f
        counter = counter+1;
    end
    cd(Path_to_save)
    save('Layer_val.mat');
    save('New_net',name)
end
clear Test_f
clear Train_f
clear Test_diff
clear Val_f
clear New_net
clear net
clear imdsTrain
clear imdsTest
clear imdsValidation
clear imds_diff
clear imds


