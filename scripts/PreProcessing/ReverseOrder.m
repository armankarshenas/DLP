%% Reverse order 
% This script reverses the order of images in the image stack 

%% Specification
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to the directory with the image stack
ext = "*." + file_format;
%% Reverse the order 
cd(Path_to_data)
FILES = dir(fullfile(pwd,ext));
for i=1: length(FILES)
    name = FILES(i).name;
    name = split(name,"_");
    name = name{1};
    k = length(FILES)-i;
    ext = split(ext,"*");
    ext = ext{2};
    if k<10
        Name = string(0)+string(0)+string(0) + string(k) + ext;
    elseif k<100
        Name = string(0)+string(0) + string(k) + ext;
    elseif k<1000
        Name = string(0) + string(k) + ext;
    else
        Name = string(k) + ext;
    end
    name = name + "_" + Name;
    movefile(FILES(i).name,name);
    fprintf("%s \n",FILES(i).name);
end
