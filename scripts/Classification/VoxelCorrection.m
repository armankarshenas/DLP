%% Voxel correction
% This script converts length from number of slices to mm using the
% Metadata_analyser function 

%% Specification 
file_format = "*.xlsx"; % Specify the file format if not excel (e.g txt/csv,etc)
Path_to_data = "";% Specify the path to the directory containing the measurement files  
Path_to_save = "";% Specify the path to directory in which processed measurements will be saved
Path_to_raw_data = ""; % Specify the path to the top level directory in which all sub-directories with images are 
addpath(genpath(pwd));

%% Conversion 
cd(Path_to_data)
Data = dir(fullfile(pwd,file_format));
Data = readtable(Data(1).name);
cd(Path_to_raw_data)
D = dir(pwd);
OR = ["AP","LR","DV"];
VXsz = zeros(1,3);
table_idx = [3,12,18,23];
for i=1:length(D)
	if((length(D(i).name) > 3))
		cd(D(i).folder + "/" + D(i).name)
		name = D(i).name;
		fprintf("Processing %s \n",name);
		name =split(name," ");
		name = name{1};
		cond = ismember(Data{:,1},name);
		if any(cond)
			for j=1:3
				VXsz(j) = Metadata_analyser(pwd,OR(j));
				Data{cond,table_idx(j):table_idx(j+1)} = Data{cond,table_idx(j):table_idx(j+1)}.*VXsz(j);
			end
		end
	end
	cd(Path_to_save)
	writetable(Data,"Measurements_mm.xlsx");
end
