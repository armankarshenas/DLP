% This script is to prep association files for Manhattan plots
path_to_assoc_files = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association";
cd(path_to_assoc_files);
Files = dir(fullfile(pwd,"*lrt.txt"));
%% Main code 
for f=1:length(Files)
   T = readtable(Files(f).name);
   % Replace the chr1 with just 1
   fprintf("Processing %s ... \n",Files(f).name);
   Chr = string(T{:,1});
   Chr = split(Chr,"chr");
   Chr = Chr(:,2);
   T.Chromosome = str2double(Chr);
   writetable(T,Files(f).name,'delimiter','\t');
end