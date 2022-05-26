# This script was written to generate scatter plots for significant SNPs 

# Loading libraries 

library(readxl)
library(readr)
library(data.table)
library(reticulate)
library(matlab)
library(ggplot2)

# Specifying the paths 
path_to_genotype <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association/genotypes"
path_to_assoc_files <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association"
path_to_phenotypes <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/"
path_to_save <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/Figures/ANGSD/geno-pheno-scatterv2"
path_to_order = "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct";

# loading the metadata
Genome_lookup = c(1,10,11,12,13,14,15,16,17,18,19,2,20,22,23,3,4,5,6,7,8 ,9)
print("Reading the metadata ... ")
setwd(path_to_phenotypes)
Phenotypes <- read_excel("ct_scan_final_dataset.xlsx")
setwd(path_to_order)
Order <- read_delim("ct_scan_corrected_data_220221_formated_sub1_samples.txt",delim = '\t',col_names = FALSE)
setwd(path_to_assoc_files)
Sig_pvalue = 8
Variables = list.files(".","*ed_lrt.txt")
setwd(path_to_genotype)
Geno_files <- list.files(".","*.geno.gz")
# Initialising the plot lists 
plot_list <- list()
plot_names <- list() 
counter <- 1
for (var in 16:length(Variables)){
  print(paste("Processing ",Variables[var],"...",sep = ""))
  setwd(path_to_assoc_files)
  tb <- read_delim(Variables[var],delim = "\t")
  # Finding the significant peaks 
  tb$P_log <- -log10(tb$LRT_Pval)
  tb <- tb[tb$P_log>=Sig_pvalue,]
  tb <- tb[order(tb$P_log,decreasing = TRUE),]
  # Writing the tables for further analysis 
  setwd(path_to_assoc_files)
  name.file <- Variables[var]
  name.file <- strsplit(name.file,"_lrt.txt")
  name.file <- unlist(name.file)
  name.file <- paste(name.file,"_sorted_peaks5.txt",sep = "")
  #write.table(tb,name.file,sep = "\t",row.names = FALSE)
  tb.minmaf <- tb[tb$Frequency >= 0.1, ]
  name.file <- Variables[var]
  name.file <- strsplit(name.file,"_lrt.txt")
  name.file <- unlist(name.file)
  name.file <- paste(name.file,"_sorted_peaks10.txt",sep = "")
  #write.table(tb.minmaf,name.file,sep = "\t",row.names = FALSE)
  if (nrow(tb) != 0){
    for (peak in 1:nrow(tb)){
      print(paste("Processing peak ",peak,"...",sep = ""))
      # first load the right geno file
      chr <- unlist(tb[peak,1])
      chr <- strsplit(chr,"chr")
      chr <- unlist(chr)
      chr <- as.double(chr[2])
      geno.index <- match(chr,Genome_lookup)
      # Load the correct genotype file 
      setwd(path_to_genotype)
      GG <- fread(Geno_files[geno.index])
      # Find the SNP
      gg <- GG[as.double(GG$V2) == as.double(unlist(tb[peak,2])),]
      # Determine the genotype for the individuals 
      gg <- as.double(gg[1,c(3:347)])
      # Phenotype variable 
      name.file <- Variables[var]
      name.file <- strsplit(name.file,"_covar2_filtered_lrt.txt") 
      var.file <- unlist(name.file)
      var.file <- strsplit(var.file,"var")
      var.file <- unlist(var.file)
      var.file <- as.double(var.file[2])
      X <- zeros(1,115)
      Y <- zeros(1,115)
      Species <- zeros(1,115)
      Population <- zeros(1,115)
      for (indiv in 1:115){
        genotype <- gg[c(((indiv-1)*3+1):(indiv*3))]
        genotype <- which.max(genotype) -1 
        X[indiv] <- genotype
        # phenotyping 
        phenotype <- Phenotypes[Phenotypes$sangerID == unlist(Order$X1[indiv]),]
        Species[indiv] <- unlist(phenotype[1,5])
        Population[indiv] <- unlist(phenotype[1,6])
        Y[indiv] <- unlist(as.double(phenotype[1,var.file]))
      }
      # Adding random values to the genotype values 
      X <- X + rnorm(length(X),0,0.1)
      
      D <- data.frame(c(X),c(Y),c(Species),c(Population))
      colnames(D) <- c("X","Y","Species","Population")
      

      
      # Getting title information 
      plot.title <- paste(tb$Chromosome[peak],"_pos:",tb$Position[peak],"_(",tb$Major[peak],",",tb$Minor[peak],")_af:",tb$Frequency[peak],"_p-value:",tb$P_log[peak],sep="")
      # File name for species 
      file.name.species <- paste("Var",var.file,"_",peak,".png",sep = "")
      plot_names[[counter]] <- file.name.species
      # Plotting the scatter plot for species 
      plot_list[[counter]] <- ggplot(D,aes(x=X,y=Y,color=Population,shape=Species)) + geom_point() + labs(x="MAP Genotype (RR/RA/AA)",y=paste("Var",var.file,"trait",sep = " "),title = plot.title) + coord_cartesian(xlim = c(-1, 3))
      counter <- counter +1 
    }
  }
  # Saving the plots 
  dir.name <- strsplit(Variables[var],"_covar2_filtered_lrt.txt")
  dir.name <- unlist(dir.name)
  setwd(path_to_save)
  dir.create(dir.name)
  setwd(dir.name)
  # Saving the plots 
  if (nrow(tb) != 0){
    for (i in 1:(counter-1)){
      png(plot_names[[i]],width = 5,height=5,units='in',res=300)
      print(plot_list[[i]])
      dev.off()
    }}
  counter <-1
  plot_names <- list()
  plot_list <- list()
}




