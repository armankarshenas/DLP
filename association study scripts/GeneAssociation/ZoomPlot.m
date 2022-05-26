% This script generates plots for the significant peaks found in GWAS using the plot_zoom package
GWAS_version = 1.02;
path_to_sigpeaks = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/GWAS_data/GWAS"+string(GWAS_version)+"/SignificantPeaks";
path_to_save = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/Figures/GWAS"+string(GWAS_version)+"/ZoomPlot";
path_to_assoc_files = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/output";
path_to_plotzoom = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Libraries/plot_zoom";
path_to_bed = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/ZoomPlot/afra_zebra_all";
path_to_annotation = "~/rds/rds-durbin-group-8b3VcZwY7rY/ref/fish/Astatotilapia_calliptera/fAstCal1.2/gtf/Astatotilapia_calliptera.fAstCal1.2.99.chr.gtf";

AFS = dir(fullfile(path_to_assoc_files,"*.assoc.txt"));
for i=1:length(AFS)
	name = split(AFS(i).name,".assoc");
	name = name{1};
	fprintf("Processing %s",name);
	input = char(path_to_assoc_files);
	input = [input '/' char(AFS(i).name)];
	cd(path_to_sigpeaks)
	cd(name)
	load_name = name +".txt";
	Peaks = readtable(load_name);
	for j=1:height(Peaks)
		chrom = Peaks{j,1};
		chrom = char(string(chrom));
		pos = Peaks{j,3};
		window_l = pos - 200000;
		window_u = pos + 200000;
		pos = char(string(pos));
		window = [char(string(window_l)) ',' char(string(window_u))];
		cd(path_to_save);
		mkdir(name)
		output_path = path_to_save + "/"+name+"/Peak"+string(j);
		output_path = char(output_path);
		Bash = fullfile(path_to_plotzoom,'plot_zoom.sh');
		cmd = [char(Bash) ' -i ' input ' -t 14 -a ' char(path_to_annotation) ' -b ' char(path_to_bed) ' -o ' output_path ' -c ' chrom ' -p ' pos ' -w ' window ' -s bfc -d 1.5 -f 2 -g 0'];
		fprintf("Processing %s",cmd);
	      system(cmd);	     
	      pause();
	end





end


