%% Align images' centers
% This script finds the center of images using the summary statistics
% measures and translate images such that their centers are aligned.

%% Specification

file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to top level directory containing all the sub-directories
Path_to_save = "";% Specify the path to directory in which aligned images will be saved
addpath(genpath(pwd));
ext = "*."+file_format;

%% Centre
cd(Path_to_data);
IMG = dir(fullfile(pwd,ext));
cd(Path_to_save)
for j = 1: length(IMG)
    I = uint8(imread(IMG(j).folder+"/"+IMG(j).name));
    mu_x = mean(I);
    L = find(mu_x<=median(mu_x));
    a = max(L(L<=(size(I,2)/2)));
    b = min(L(L>=(size(I,2)/2)));
    cx = a+ceil((b-a)/2);
    mu_y = mean(I,2);
    L = find(mu_y<=median(mu_y));
    a = max(L(L<=size(I,1)/2));
    b = min(L(L>=size(I,1)/2));
    cy = a+ceil((b-a)/2);
    kx = ceil(size(I,2)/2) - cx;
    ky = ceil(size(I,1)/2) - cy;
    if ~isempty(kx) && ~isempty(ky)
        I = imtranslate(I,[kx;ky;]);
    end
    name = Order_name(j,".jpg");
    I = uint8(imclearborder(I,8));
    imwrite(I,name,'JPEG');
    fprintf("%s \n",IMG(j).name);
end




