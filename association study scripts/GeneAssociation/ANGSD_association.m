% This script filters the ANGSD output files and calculate LRT p-value

%% Paths and metadata 
path_to_assoc_files = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association";
cd(path_to_assoc_files);
Files = dir(fullfile(pwd,"*lrt0.txt"));
%% Main code 
for f=1:length(Files)
   T = readtable(Files(f).name);
   % Computing the LRT_pval 
   fprintf("Processing %s ... \n ",Files(f).name);
   LRT_pval = 1-chi2cdf(table2array(T(:,7)),1);
   T(:,9) = table(LRT_pval);
   T.Properties.VariableNames(9) = {'LRT_Pval'};
   name = Files(f).name;
   name = split(name,".txt");
   name = name{1};
   name = name + "_pval"+".txt";
   writetable(T,name,'delimiter','\t');
   % Deleting the rows
   to_delete = T.LRT == -999;
   T(to_delete,:) = [];
   name = split(name,"_pval");
   name = name{1};
   name = split(name,".lrt");
   name = name{1};
   name = name + "_filtered_lrt.txt";
   writetable(T,name,'delimiter','\t');
   delete(Files(f).name);
end