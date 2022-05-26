%This script uses the mat files to plot the box plots for all the sig peaks in the GWAS 

path_to_save = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/Figures/GWAS2.01/geno-pheno-scatter";
path_to_mat = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/GWAS_data/GWAS2.01/SignificantPeaks";
cd(path_to_mat)
Variables = dir(pwd)

for i=1:length(Variables)
	if contains(Variables(i).name,"var")
		cd(Variables(i).name)
		load_name = Variables(i).name;
		load_name = load_name + ".mat";
		load(load_name);
		cd(path_to_save);
		mkdir(Variables(i).name);
		cd(Variables(i).name);
		if (length(fieldnames(Data)) > 0)
			counter = 1;
			for p=1:length(Data.peak)
				genotype = round(Data.peak{p}.genotype);
				No0 = length(genotype(genotype <= 0.5));
				Het = genotype(genotype > 0.5);
				No1 = length(Het(Het<=1.5));
				No2 = length(Het(Het > 1.5));
				RAF = (No1+No2*2)/(length(genotype));
				if RAF >= 0.05 
				species = categorical(Data.peak{p}.species);
				gscatter(Data.peak{p}.genotype,Data.peak{p}.phenotype,species,['r','b']);
				TXT = "af: " + Data.peak{p}.af + " beta: " + Data.peak{p}.beta + " pos: " + Data.peak{p}.pos + " p-value: " + Data.peak{p}.pvalue;
				xlabel("Genotype","interpreter","latex","FontSize",14);
				ylabel("Phenotype (m)","interpreter","latex","FontSize",14);
				grid on;
				title(TXT,'FontSize',15);
				name = split(Variables(i).name,"_");
				name = name{1};
				save_name = name + "_peak" + string(counter) + ".png"
				saveas(gcf,save_name);
				counter = counter + 1;
				end
			end
		end
		cd(path_to_mat);
	end
end
