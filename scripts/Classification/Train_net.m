function [New_net,acc,preds,prb] = Train_net(imdsTrain,imdsValidation,imdsTest,net,li,n_class)
%TRAIN_NET Summary of this function goes here
%   Detailed explanation goes here
inputSize = net.Layers(1).InputSize;
% Extract features using the convolutional layer of the pre-trained network

pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandYReflection',true,'RandXTranslation',pixelRange,'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);
augimdsTest = augmentedImageDatastore(inputSize(1:2),imdsTest,'ColorPreprocessing','gray2rgb');
augimdsVal = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);

Train_f = activations(net,augimdsTrain,li{1});
Test_f = activations(net,augimdsTest,li{1});
Val_f = activations(net,augimdsVal,li{1});


% Layers for the new network

layer = [
    imageInputLayer([size(Train_f,1) size(Train_f,2) size(Train_f,3)])
    fullyConnectedLayer(n_class)
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
    'Plots','none',...
    'LearnRateDropFactor',0.95, ...
    'LearnRateSchedule','piecewise',...
    'InitialLearnRate',1e-3);
% Train the network
New_net = trainNetwork(Train_f,imdsTrain.Labels,layer,options);
% Test the network
[preds,prb] = classify(New_net,Test_f);
acc = nnz(preds == imdsTest.Labels)/length(imdsTest.Files);


end

