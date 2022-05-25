%% Semantic Segmentation
%% Spec
orien = "AP";
Spec = "Z";
fprintf("initialising ... \n");

%% Creating cells for image data and label data 
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg
cd(orien)
cd(Spec)
load('gTruth.mat');
%% Loading stuff
% load the gtruth labelled images: 
fprintf("Loading images and labels ... \n");
%{
load('gTruth.mat');
% correcting the path 
cpath1 = gTruth.DataSource{1};
cpath1 = split(cpath1,"/");
cp1 = "";
for i=2:length(cpath1)-1
    cp1 = cp1 + "/" + cpath1{i};
end
des1 = "~rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg/"+orien+"/"+Spec+"/Images";
alt_1 = {[cp1 des1]};
unres_path1 = changeFilePaths(gTruth,alt_1);

cpath2 = gTruth.LabelData{1};
cpath2 = split(cpath2,"/");
cp2 = "";
for i=2:length(cpath2)-1
    cp2 = cp2 + "/" + cpath2{i};
end

des2 = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg/"+orien+"/"+Spec+"/PixelLabelData";
alt_2 = {[cp2 des2]};
unres_path2 = changeFilePaths(gTruth,alt_2);
%}
%% Loading pixelDatastore
fprintf("Creating PixelDatastore ... \n");
Px = pixelLabelDatastore(gTruth);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ML-DATASET/Semantic_seg
cd(orien)
cd(Spec)
imds = imageDatastore('Semantic_try');
classes = Px.ClassNames;

I = readimage(imds,2);
C = readimage(Px,2);
cmap = ArmanColorMap;
B = labeloverlay(I,C,'Colormap',cmap);
imshow(B);
pixelLabelColorbar(cmap,Px.ClassNames);
savefig("Labelled-semantic.fig");
close
%% Analyse the dataset stats 
fprintf("Analysing the dataset ... \n");
tbl = countEachLabel(Px);
frequency = tbl.PixelCount/sum(tbl.PixelCount);

bar(1:numel(classes),frequency)
xticks(1:numel(classes)) 
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')
savefig("Bias_issue.fig");
close

%% Partition the dataset 
fprintf("Partioning the dataset ... \n");
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionData(imds,Px);
numTrainingImages = numel(imdsTrain.Files)
numValImages = numel(imdsVal.Files)
numTestingImages = numel(imdsTest.Files)

%% Create the network 
fprintf("Creating the network ... \n");

imageSize = [224 224,3];
numClasses = numel(classes);
lgraph = deeplabv3plusLayers(imageSize, numClasses, "resnet50");

%% Balance the classes 
fprintf("Analysing class bias ... \n");

imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq
pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);

%% Train the network 
fprintf("Training network ... \n");
pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal,'OutputSize',imageSize(1:2),'ColorPreprocessing','gray2rgb');
tempdir = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Segment_network";
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',pximdsVal,...
    'MaxEpochs',30, ...  
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',2,...
    'Plots','none',...
    'ValidationPatience', 4);

augmenter = imageDataAugmenter('RandXReflection',true,'RandXTranslation',[-10 10],'RandYTranslation',[-10 10]);
pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain,'DataAugmentation',augmenter,'OutputSize',imageSize(1:2),'ColorPreprocessing','gray2rgb');
augtest = augmentedImageDatastore(imageSize(1:2),imdsTest,'ColorPreprocessing','gray2rgb');
%network = trainNetwork(pximds,lgraph,options);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272
%save('AP_Segment_bv3.mat','network');
load("AP_Segment_bv3.mat");


%% Evaluate 
I = readimage(imdsTest,13);
C = semanticseg(I, network);
B = labeloverlay(I,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
pixelLabelColorbar(cmap, classes);
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272
savefig('TestImage1.fig');
close
expectedResult = readimage(pxdsTest,7);
actual = uint8(C);
expected = uint8(expectedResult);
figure;
imshowpair(actual, expected)
savefig('Jaccard.fig');
close

pxdsResults = semanticseg(augtest,network,'MiniBatchSize',4,'WriteLocation',tempdir,'Verbose',true)
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',true)
cd ~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272
save('Metrics.mat','metrics');




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
