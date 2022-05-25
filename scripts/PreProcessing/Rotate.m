%% Rotate
%This script rotates images counter clockwise by $angle degrees 

%% Specification 
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to the directory with the image stack
Path_to_save = "";% Specify the path to directory in which rotated images will be saved
ext = "*."+file_format;

%% Rotation
cd(Path_to_data)
FILES = dir(fullfile(pwd,ext));
cd(Path_to_save)
for i=1: length(FILES)
    I = uint8(imread(FILES(i).folder + "/"+FILES(i).name));
    I = imrotate(I,angle);
    imwrite(I,FILES(i).name);
    fprintf("%s \n",FILES(i).name);
end
