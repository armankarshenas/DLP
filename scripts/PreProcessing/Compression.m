%% Compression script 
% This script compresses images using bit truncation determined by
% the randomness analysis (Randomness.m). The user should specify the
% number of bits to be truncated, and the script reads, compresses and
% writes image stacks using LZW compression. This compression script can
% achieve compression ratio of up to 15 without any significant loss to the
% information content of the image. 

%% Specifications 
clear
clc
close all
bit_removed = 10; % Specify the number of bits here 
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to top level directory containing all the sub-directories 
Path_to_save = "";% Specify the path to directory in which compressed images will be saved
%% The loop over all files 
cd(Path_to_data);
all_d = dir(pwd);
for direc=1:length(all_d)
    if (all_d(direc).isdir == 1) && (length(all_d(direc).name) >5)
        % We implemented this part to keep a consistant nomenclature across
        % all of our sample images - please change if needed or leave
        % commented if the directories are already following a uniform
        % nomenclature. 
        long_name = all_d(direc).name;
        %{
        ID = split(long_name," ");
        ID = ID(1);
        Date = split(long_name," [");
        Date = Date(2);
        Date = split(Date," ");
        Date = Date(1);
        Date = split(Date,"-");
        year = char(Date(1));
        year = year(3:4);
        month = Date(2);
        day = Date(3);
        New_name=ID+"_"+year+month+day;
        %}
        New_name = long_name;
        fprintf("%s \n",New_name);
        
        % Now we cd to each of the directories to compress the images
        cd(all_d(direc).folder+"/"+long_name);
        mydir =pwd;
        file_format = "*." + file_format;
        dirPattern = fullfile(mydir,file_format);
        % Creating a list of image files 
        IMG = dir(dirPattern);
        % cd to the path provided to save the compressed images 
        cd(Path_to_save)
        mkdir(New_name)
        cd(New_name)
        
        for i=1:length(IMG)
            % load the image
            if (IMG(i).isdir ~= 1)
                I = imread(IMG(i).folder+"/"+IMG(i).name);
                fprintf("%s \n",IMG(i).name);
                m = size(I,1);
                n = size(I,2);
                BI = uint16(zeros(size(I,1),size(I,2)));
                for dim_1 = 16:-1:16-bit_removed
                    BI = BI + bitget(I,dim_1).*(2^(dim_1-bit_removed));
                end
                I = BI;
                clear BI;
                I = uint8(I);
                I = imadjust(I,stretchlim(I),[]);
                imwrite(I,IMG(i).name,'Compression','lzw');
                
            end
        end
        
    end
end