path_to_bimbam = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct";
path_to_order = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct";
path_to_assoc_files = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/covar_set2/output";
path_to_phenotypes = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/";
path_to_save = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/GWAS_data/GWAS2.11/SignificantPeaks";
cd(path_to_bimbam)
%Genotype_file_ID = fopen("ct_scan_corrected_data_220221_sub1_genofilter1.bimbam",'rt');
GG = readlines("ct_scan_corrected_data_220221_sub1_genofilter1.bimbam");
cd(path_to_phenotypes)
Phenotypes = readtable("ct_scan_final_dataset.xlsx");
cd(path_to_order)
Order = readtable("ct_scan_corrected_data_220221_formated_sub1_samples.txt",'ReadVariableNames',false);
Order = string(table2array(Order));
cd(path_to_assoc_files);
Sig_pvalue = 7.7
allele_freq_cut = 0.05;
Variables = dir(fullfile(pwd,"*assoc.txt"));

for var =1 :length(Variables)
	%frewind(Genotype_file_ID);
	Data = struct();
	cd(path_to_assoc_files)
	tb = readtable(Variables(var).name);
        Results = table();
        log_pvalue = -log10(table2array(tb(:,14)));
	tb = addvars(tb,log_pvalue);
	tb_idx = table2array(tb(:,end)) >= Sig_pvalue;
	tb_idx_af = table2array(tb(:,7)) >= allele_freq_cut;
	tb_idx = tb_idx & tb_idx_af;
	Results = tb(tb_idx,:);
	name = Variables(var).name;
	name = split(name,".");
	name = name{1};
	fprintf("Processing Variable %s \n",name);
	peak_counter = 1;
	for pos = 1:height(tb)
		%waitbar(pos/height(tb),"Scanning SNPs");
		if tb_idx(pos) == 1
			fprintf("Processing peak %d \n",pos);
			%txt = fgetl(Genotype_file_ID);
		       	G = split(GG(pos),",");
			Phenotypes.sangerID = categorical(Phenotypes.sangerID);
			Data.peak{peak_counter}.phenotype = zeros(1,height(Phenotypes));
			Data.peak{peak_counter}.genotype = zeros(1,height(Phenotypes));
			Data.peak{peak_counter}.pos = string(table2array(Results(peak_counter,2)));
			Data.peak{peak_counter}.af = table2array(Results(peak_counter,7));
			Data.peak{peak_counter}.beta = table2array(Results(peak_counter,8));
			Data.peak{peak_counter}.pvalue = table2array(Results(peak_counter,16));
Data.peak{peak_counter}.GG = G;
			var_name = Variables(var).name;
			var_name = split(var_name,"_var");
			var_name = var_name{2};
			var_name = split(var_name,".");
			var_name = var_name{1};
			var_name = "Var"+var_name;
			for ind = 1:length(G)-3
				ind_phen = Phenotypes(Phenotypes.sangerID == Order(ind),:);
				Data.peak{peak_counter}.phenotype(ind) = table2array(ind_phen(1,var_name));
				Data.peak{peak_counter}.genotype(ind) = str2double(G(ind+3))
				species = table2array(ind_phen(1,"Species"));
				Data.peak{peak_counter}.species(ind) = string(species{1});
				sangerID = table2array(ind_phen(1,"sangerID"));
				Data.peak{peak_counter}.sangerID(ind) = string(sangerID);
				fprintf("Processing %s \n",string(sangerID));
			end
			peak_counter = peak_counter +1;

		else 
			%txt = fgetl(Genotype_file_ID);
		end
	end
	clear peak_counter;
	cd(path_to_save)
	mkdir(name)
	cd(name);
	save_name = name + ".mat";
	save(save_name,'Data');
	save_name = name + ".txt";
	writetable(Results,save_name);
end
