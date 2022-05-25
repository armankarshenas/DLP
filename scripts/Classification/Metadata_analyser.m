%% Find Voxel sizes
% This function extracts the metadata and the voxel size from the xtekct
% files
function [Voxel_sz] = metadata_analyser(path,orient)
cd(path);
f = dir(fullfile(pwd,"*.xtekct"));
for i=1:length(f)
    PATH = f(i).folder +"/"+f(i).name;
    ops = detectImportOptions(PATH,'FileType','delimitedtext','ExpectedNumVariables',2,'ReadVariableNames',false);
    Meta_Data = readtable(PATH,ops);
    Meta_Data.Properties.VariableNames{'Var1'} = 'Parameter';
    Meta_Data.Properties.VariableNames{'Var2'} = 'Values';
    
    % finding voxel sizes
    if orient == "AP"
        orient = "Z";
    elseif orient == "LR"
        orient = "X";
    elseif orient == "DV"
        orient = "Y";
    else
        fprintf("The orientation provided is not compatible");
    end
    
    sz_name = "VoxelSize" + orient;
    cond = ismember(Meta_Data{:,1},sz_name);
    Voxel_sz = Meta_Data{cond,2}.*1e-3;
    
end
end
