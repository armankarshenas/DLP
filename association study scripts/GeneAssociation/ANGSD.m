% This script process the mean posteriori genotype files and plots the
% genotype-phenotype scatter plots
%% Adding the libraries into the path
addpath(genpath("~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Libraries"));
%% Paths
path_to_genotype = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association/genotypes";
path_to_order = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct";
path_to_assoc_files = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association";
path_to_phenotypes = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/";
path_to_save = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/GWAS_data/ANGSD/SignificantPeaks";
%% Reading the metadata
fprintf("Reading the metadata ... \n");
cd(path_to_phenotypes)
Phenotypes = readtable("ct_scan_final_dataset.xlsx");
cd(path_to_order)
Order = readtable("ct_scan_corrected_data_220221_formated_sub1_samples.txt",'ReadVariableNames',false);
Order = string(table2array(Order));
cd(path_to_assoc_files);
Sig_pvalue = 7.7
allele_freq_cut = 0.05;
Variables = dir(fullfile(pwd,"*_lrt.txt"));

%% Genotype decompression and reading the files
fprintf(".geno file preparation ... \n");
cd(path_to_genotype)
% Reading the decompressed files
GG_files = natsortfiles(dir("*.geno"));
%{
GG =[];
for i=1:length(GG_files)
    T = readlines(GG_files(i).name);
    T = T(1:end-1);
    GG = [GG;T;];
end
%}
%% Main for loop
fprintf("Main code running ... \n");
for var =1 :length(Variables)
    Data = struct();
    cd(path_to_assoc_files)
    tb = readtable(Variables(var).name);
    Results = table();
    tb_idx = table2array(tb(:,7)) >= Sig_pvalue;
    tb_idx_af = table2array(tb(:,5)) >= allele_freq_cut;
    tb_idx = tb_idx & tb_idx_af;
    Results = tb(tb_idx,:);
    name = Variables(var).name;
    name = split(name,".");
    name = name{1};
    fprintf("Processing Variable %s \n",name);
    peak_counter = 1;
    cd(path_to_genotype)
    % Read the first chromosome
    GG = readlines(GG_files(1).name);
    chr = 1;
    c_pos = 0;
    for pos = 1:height(tb)
        check_chr = string(tb{pos,1});
        check_chr = split(check_chr,"chr");
        check_chr = check_chr{2};
        check_chr = str2double(check_chr);
        if ((tb_idx(pos) == 1) && (check_chr == chr))
            fprintf("Processing peak %d \n",pos);
            fprintf("Chromosome %d \n",chr);
            G = split(GG(pos-c_pos));
            Phenotypes.sangerID = categorical(Phenotypes.sangerID);
            Data.peak{peak_counter}.phenotype = zeros(1,height(Phenotypes));
            Data.peak{peak_counter}.genotype = zeros(1,height(Phenotypes));
            Data.peak{peak_counter}.pos = string(table2array(Results(peak_counter,2)));
            Data.peak{peak_counter}.af = table2array(Results(peak_counter,5));
            Data.peak{peak_counter}.beta = "NA";
            Data.peak{peak_counter}.pvalue = table2array(Results(peak_counter,7));
            var_name = Variables(var).name;
            var_name = split(var_name,"var");
            var_name = var_name{2};
            var_name = split(var_name,"_");
            var_name = var_name{1};
            var_name = "Var"+var_name;
            G = G(3:end-1);
            G = str2double(G);
            G = reshape(G,3,115);
            G = G';
            for ind = 1:length(G)
                gg = G(ind,:);
                [~,index] = max(gg);
                gg = index-1;
                ind_phen = Phenotypes(Phenotypes.sangerID == Order(ind),:);
                Data.peak{peak_counter}.phenotype(ind) = table2array(ind_phen(1,var_name));
                Data.peak{peak_counter}.genotype(ind) = gg;
                species = table2array(ind_phen(1,"Species"));
                Data.peak{peak_counter}.species(ind) = string(species{1});
                sangerID = table2array(ind_phen(1,"sangerID"));
                Data.peak{peak_counter}.sangerID(ind) = string(sangerID);
                %fprintf("Processing %s \n",string(sangerID));
            end
            peak_counter = peak_counter +1;
            
        elseif ((tb_idx(pos)==1) && (check_chr ~= chr))
            fprintf("Chromosome %d \n",check_chr);
            chr = check_chr;
            c_pos = c_pos + pos -1;
            cd(path_to_genotype)
            GG = readlines(GG_files(check_chr).name);
            fprintf("Processing peak %d \n",pos);
            G = split(GG(pos-c_pos));
            Phenotypes.sangerID = categorical(Phenotypes.sangerID);
            Data.peak{peak_counter}.phenotype = zeros(1,height(Phenotypes));
            Data.peak{peak_counter}.genotype = zeros(1,height(Phenotypes));
            Data.peak{peak_counter}.pos = string(table2array(Results(peak_counter,2)));
            Data.peak{peak_counter}.af = table2array(Results(peak_counter,5));
            Data.peak{peak_counter}.beta = "NA";
            Data.peak{peak_counter}.pvalue = table2array(Results(peak_counter,7));
            var_name = Variables(var).name;
            var_name = split(var_name,"var");
            var_name = var_name{2};
            var_name = split(var_name,"_");
            var_name = var_name{1};
            var_name = "Var"+var_name;
            G = G(3:end-1);
            G = str2double(G);
            G = reshape(G,3,115);
            G = G';
            for ind = 1:length(G)
                gg = G(ind,:);
                [~,index] = max(gg);
                gg = index-1;
                ind_phen = Phenotypes(Phenotypes.sangerID == Order(ind),:);
                Data.peak{peak_counter}.phenotype(ind) = table2array(ind_phen(1,var_name));
                Data.peak{peak_counter}.genotype(ind) = gg;
                species = table2array(ind_phen(1,"Species"));
                Data.peak{peak_counter}.species(ind) = string(species{1});
                sangerID = table2array(ind_phen(1,"sangerID"));
                Data.peak{peak_counter}.sangerID(ind) = string(sangerID);
                %fprintf("Processing %s \n",string(sangerID));
            end
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
