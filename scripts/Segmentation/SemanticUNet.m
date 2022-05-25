%% Spec
orien = "AP";
Spec = "Z";
fprintf("initialising ... \n");

%% Loading stuff
% load the gtruth labelled images: 
fprintf("Loading images and labels ... \n");

cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg
cd(orien)
cd(Spec)

load('gTruth.mat');
%% Loading pixelDatastore
fprintf("Creating PixelDatastore ... \n");
Px = pixelLabelDatastore(gTruth);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg
cd(orien)
cd(Spec)
imds = imageDatastore('Semantic_try');
classes = Px.ClassNames;

% Visualisation

I = readimage(imds,2);
C = readimage(Px,2);
cmap = ArmanColorMap;
B = labeloverlay(I,C,'Colormap',cmap);
imshow(B);
pixelLabelColorbar(cmap,Px.ClassNames);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272
savefig('3.fig');
close
%% Analyse the dataset stats 

tbl = countEachLabel(Px);
frequency = tbl.PixelCount/sum(tbl.PixelCount);
bar(1:numel(classes),frequency)
xticks(1:numel(classes)) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')
savefig('4.fig');
close
%% Partition the dataset 
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData(imds,Px);
numTrainingImages = numel(imdsTrain.Files)
numValImages = numel(imdsVal.Files)
numTestingImages = numel(imdsTest.Files)

%% U net 

imageSize = [512 512];
numClasses = 4;
lgraph = unetLayers(imageSize, numClasses);

pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal,'OutputSize',imageSize(1:2));
augmenter = imageDataAugmenter('RandXReflection',true,'RandXTranslation',[-10 10],'RandYTranslation',[-10 10]);
pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,'OutputSize',imageSize(1:2),'DataAugmentation',augmenter);
augtest = augmentedImageDatastore(imageSize(1:2),imdsTest);
%% Balance the classes 
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"Segmentation-Layer",pxLayer);


%% Train 
options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MiniBatchSize',8, ... 
    'Plots','none', ...
    'ValidationData',pximdsVal, ...
    'ValidationFrequency',2,...
    'ValidationPatience',4,...
    'LearnRateDropFactor',0.95,...
    'LearnRateSchedule','piecewise',...
    'Verbose',1,...
    'MaxEpochs',30, ...
    'VerboseFrequency',1);
net = trainNetwork(pximds,lgraph,options);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272
save('U_net.mat','net');


%% Evaluation 
I = readimage(imdsTest,7);
C = semanticseg(I, net);
B = labeloverlay(I,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
pixelLabelColorbar(cmap, classes);
savefig('1.fig');
close
expectedResult = readimage(pxdsTest,7);
actual = uint8(C);
expected = uint8(expectedResult);
figure;
imshowpair(actual, expected)
savefig('2.fig');
close
iou = jaccard(C,expectedResult);
table(classes,iou)

%% Evaluate the test dataset

pxdsResults = semanticseg(augtest,net,'MiniBatchSize',4,'WriteLocation',tempdir,'Verbose',true)
metrics = evaluateSemanticSegmentation(pxdsResults,pxTest,'Verbose',true)




%% Functions 

function out = RS(data,inputSize)
out{1} = imresize(data{1},inputSize);
out{2} = imresize(data{2},inputSize);
end

function cmap = ArmanColorMap()
% Define the colormap used by CamVid dataset.

cmap = [
    0 128 0   % Background
    128 0 0       % Frontal_jaw
    0 0 128   % Soft_tissue
    128 64 128    % Fish   
    ];
% Normalize between [0 1].
cmap = cmap ./ 255;
end

function pixelLabelColorbar(cmap, classNames)
% Add a colorbar to the current axis. The colorbar is formatted
% to display the class names with the color.

colormap(gca,cmap)

% Add colorbar to current figure.
c = colorbar('peer', gca);

% Use class names for tick marks.
c.TickLabels = classNames;
numClasses = size(cmap,1);

% Center tick labels.
c.Ticks = 1/(numClasses*2):1/numClasses:1;

% Remove tick mark.
c.TickLength = 0;
end
function [imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData(imds,pxds)
% Partition CamVid data by randomly selecting 60% of the data for training. The
% rest is used for testing.
    
% Set initial random state for example reproducibility.
rng(0); 
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 60% of the images for training.
numTrain = round(0.60 * numFiles);
trainingIdx = shuffledIndices(1:numTrain);

% Use 20% of the images for validation
numVal = round(0.20 * numFiles);
valIdx = shuffledIndices(numTrain+1:numTrain+numVal);

% Use the rest for testing.
testIdx = shuffledIndices(numTrain+numVal+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
valImages = imds.Files(valIdx);
testImages = imds.Files(testIdx);

imdsTrain = imageDatastore(trainingImages);
imdsVal = imageDatastore(valImages);
imdsTest = imageDatastore(testImages);

% Extract class and label IDs info.
classes = pxds.ClassNames;
labelIDs = 1:1:length(unique(classes));

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
valLabels = pxds.Files(valIdx);
testLabels = pxds.Files(testIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classes, labelIDs);
pxdsVal = pixelLabelDatastore(valLabels, classes, labelIDs);
pxdsTest = pixelLabelDatastore(testLabels, classes, labelIDs);
end