%% SVM feedforward
% This script runs images through the trained model to generate
% measurements

%% Specification
addpath(genpath(pwd))
Orien = "AP"; % Specify the orientation you want the script to generate (AP, LR, and DV)
Path_to_trained_model = "";% Specify the path to the directory with the trained SVM models
Path_to_imgs = ""; % Specify the path to the top level directory containing sub-directories with images
Path_to_save = "";% Specify the path to directory in which measurements will be saved
li = 'avg_pool'; % Specify the optimal layer for feature space generation
n_break = 4; % Specify the number of breaks that is expected in the given projection
%% Loading stuff
net = resnet50;
inputSize = net.Layers(1).InputSize;

cd(Path_to_trained_model)
name_m = "SVM-"+Orie+".mat";
load(name_m);

n_save_mat = Orie+"_measurements.mat";
n_save_csv = Orie+"_measurements.csv";
n_class = length(Model.ClassificationSVM.ClassNames);
n_breakpoint = n_break;
n_measures = nchoosek(n_breakpoint,2);
cd(Path_to_imgs)
cd(Orie)
DIR = dir(pwd);
temp = table();
for i=1:length(DIR)
    if length(char(DIR(i).name)) >10
        fprintf("Feedforwarding %s ...\n",DIR(i).name);
        temp{i,1} = string(DIR(i).name);
        cd(Path_to_imgs)
        cd(Orie)
        imds = imageDatastore(DIR(i).name);
        augimds = augmentedImageDatastore(inputSize(1:2),imds,'ColorPreprocessing','gray2rgb');
        I_f = activations(net,augimds,li);
        I_f = reshape(I_f,[size(I_f,3) size(I_f,4)]);
        I_f = I_f';
        [Pred,Score] = Model.predictFcn(I_f);
        [output,res] = Abnormal_removal(Pred,n_break);
        temp{i,2} = res;
        temp = Measure_qt(temp,output,n_break);
    end
end
cd(Path_to_save)
cd(Orie)
save(n_save_mat,'temp');
writetable(Measure_tb,n_save_csv);

