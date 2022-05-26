path_to_save = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/GWAS_data/GWAS2.01/SignificantPeaks";
path_to_raw_data= "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/covar_set1/output";
cd(path_to_raw_data);
Association_files = dir(fullfile(pwd,"*.txt"));
Sig_pvalue = 7.7
for i=1:length(Association_files)
	if contains(Association_files(i).name,"assoc")
        tb = readtable(Association_files(i).name);
        Results = table();
        log_pvalue = -log10(table2array(tb(:,14)));
	tb = addvars(tb,log_pvalue);
	tb_idx = table2array(tb(:,end)) >= Sig_pvalue;
	Results = tb(tb_idx,:); 
        cd(path_to_save)
        name = Association_files(i).name;
        name = split(name,".");
        name = name{1};
        mkdir(name)
        cd(name)
        writetable(Results,name);
        cd(path_to_raw_data);
end
end
