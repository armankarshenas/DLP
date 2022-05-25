function [Name] = Order_name(k,ext)
%ORDER_NAME Summary of this function goes here
%   This function returns the name of files with correct number of 0s
%   so that their order is maintained when read into image datastores.
%   For example, image 54 is named 0054 for a stack of 2000
if k<10
    Name = string(0)+string(0)+string(0) + string(k) + ext;
elseif k<100
    Name = string(0)+string(0) + string(k) + ext;
elseif k<1000
    Name = string(0) + string(k) + ext;
else
    Name = string(k) + ext;
end
end

