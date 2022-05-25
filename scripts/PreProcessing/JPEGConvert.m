%% JPEG conversion
% This script converts Tiff format images to JPEG should the user wish to
% compress images 
%% Specification
Path_to_data = "";% Specify the path to top level directory containing all the sub-directories 
Path_to_save = "";% Specify the path to directory in which compressed images will be saved
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
%% Conversion
cd(Path_to_data);
ext = "*."+file_format;
FILES = dir(fullfile(pwd,ext));
cd(Path_to_save)
name = strsplit(pwd,"/");
name = name{end};
mkdir(name)
cd(name)
for i=1: length(FILES)
    I = uint8(imread(FILES(i).folder + "/"+FILES(i).name));
    name = FILES(i).name;
    name = split(name,"."+file_format);
    name = name{1};
    name = name + ".jpg";
    imwrite(I,name,'jpg');
end
