%% ORIENTATION
%This script creates a sub directory AP, DV, LR for
%projections from that side

%% Specification
Orien = ""; % Specify the orientation you want the script to generate (AP, LR, and DV)
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to top level directory containing all the sub-directories
Path_to_save = "";% Specify the path to directory in which compressed images will be saved
ext = "*." + file_format;
addpath(genpath(pwd));
%% Create projection
cd(Path_to_data)
DIRS = dir(Path);
for i=1:length(DIRS)
    if (DIRS(i).isdir == 1) && (length(DIRS(i).name) >5)
        cd(DIRS(i).folder+"/"+DIRS(i).name);
        IMG = dir(fullfile(pwd,ext));
        Temp = imread(IMG(1).name);
        I = zeros(size(Temp,1),size(Temp,2),length(IMG),'uint8');
        I(:,:,1) = Temp;
        clear Temp;
        for j=2 : length(IMG)
            Temp = uint8(imread(IMG(j).name));
            I(:,:,j) = Temp;
        end
        if Orien == "LR"
            cd(Path_to_save)
            if ~exist("LR","dir")
                mkdir LR
                cd LR
            else
                cd LR
            end
            mkdir(DIRS(i).name)
            cd(DIRS(i).name)
            for k=1:size(Temp,2)
                name = Order_name(k,".jpg");
                Temp = reshape(I(:,k,:),[size(I(:,k,:),1) size(I(:,k,:),3)]);
                imwrite(Temp,name,'JPEG');
                fprintf("%s \n",name);
            end
        end
        
        if Orien == "DV"
            cd(Path_to_save)
            if ~exist("DV","dir")
                mkdir DV
                cd DV
            else
                cd DV
            end
            mkdir(DIRS(i).name)
            cd(DIRS(i).name)
            for k=1:size(I(:,:,1),1)
                name = Order_name(k,".jpg");
                Temp = reshape(I(k,:,:),[size(I(k,:,:),2),size(I(k,:,:),3)]);
                imwrite(Temp,name,'JPEG');
                fprintf("%s \n",name);
            end
        end
    end
end


