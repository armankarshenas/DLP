%% This script has been written to downsample the image 
function I = Downsample(I_i,ratio)
padding = 1;
stride = ratio; 
fsize = 3;
kernel = fspecial('gaussian',fsize,1);
kernel = kernel.*100;
kernel = uint8(kernel);
Temp = zeros(size(I_i,1)+2*padding,size(I_i,2)+2*padding,'uint8');
Temp(1+padding:end-padding,1+padding:end-padding) = I_i;
s_1 = floor((size(I_i,1)+2*padding-fsize)/stride+1);
s_2 = floor((size(I_i,2)+2*padding-fsize)/stride+1);
I = zeros(s_1,s_2,'uint8');

for i=1:size(I,1)
    for j=1:size(I,2)
        I(i,j) = sum(sum(Temp((i-1)*stride+1:(i-1)*stride+fsize,(j-1)*stride+1:(j-1)*stride+fsize).*kernel./max(max(kernel))));
    end
end
end
