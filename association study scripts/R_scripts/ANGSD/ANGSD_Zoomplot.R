# This script has been written to generate association files compatible with ZoomPlot

# Paths and libraries 
path_to_assoc_files <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association"
library(readr)
library(matlab)
library(readxl)
library(stringr)

# Reading the files 
setwd(path_to_assoc_files)
AFS <- list.files(".","*ed_lrt.txt")

for (i in 1:length(AFS)){
  # Reading the table
  tb <- read.delim(AFS[i],sep = "\t")
  # Chromosome column 
  names(tb)[names(tb) == "Chromosome"] <- "chr"
  
  # The rs column
  rs <- paste(tb[,1],"_",tb[,2],sep = "")
  tb$rs <-rs
  tb <- tb[,c(1,10,2,3,4,5,6,7,8,9)]
  
  # The chr column 
  chr <- tb$chr 
  chr <- str_split_fixed(chr,"chr",2)
  chr <- as.double(chr[,2])
  tb$chr <- chr
  # The position column 
  names(tb)[names(tb) == "Position"] <- "ps"
  
  # The n_miss column 
  n.miss <- rep(0,length(tb$chr))
  tb$n_miss <- n.miss
  tb <- tb[,c(1,2,3,11,4,5,6,7,8,9,10)]
  
  # The allele columns 
  names(tb)[names(tb) == "Major"] <- "allele0"
  names(tb)[names(tb) == "Minor"] <- "allele1"
  tb <- tb[,c(1,2,3,4,6,5,7,8,9,10,11)]
  
  # Frequency column 
  names(tb)[names(tb) == "Frequency"] <- "af"
  
  # Removing columns 
  tb <- tb[,c(1,2,3,4,5,6,7,11)]
  
  # beta and other columns 
  tb$beta <- rnorm(length(tb$chr),0,0.01)
  tb$se <- rnorm(length(tb$chr),0,0.4)
  tb$logl_H1 <- rep(-130,length(tb$chr))
  tb$l_remle <- rep(1e-5,length(tb$chr))
  tb$l_mle <- rep(1e-5,length(tb$chr))
  tb$p_wald <- tb$LRT_Pval
  
  # p_lrt and p_score
  names(tb)[names(tb) == "LRT_Pval"] <- "p_lrt"
  tb$p_score <- -log10(tb$p_lrt)
  
  # Final ordering of the table 
  tb <- tb[,c(1,2,3,4,5,6,7,9,10,11,12,13,14,8,15)]
  
  # Write the table into an association file
  save_name <- strsplit(AFS[i],"_covar2")
  save_name <- save_name[[1]][1]
  save_name <- paste(save_name,"_GEMMA_form_lrt.txt",sep = "")
  write.table(tb,save_name,sep = "\t",row.names = FALSE,col.names = TRUE,quote = FALSE)
  
}
