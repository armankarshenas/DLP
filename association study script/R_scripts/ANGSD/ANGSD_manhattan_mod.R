# This script is written to generate Manhattan plots for the ANGSD results
library(qqman)
library(stringr)
library(readr)
# Specifying addresses 
path_to_assoc_files <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association"
path_to_save <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/Figures/ANGSD/Manhattan"
setwd(path_to_assoc_files)
Files <- list.files(path = ".",pattern = "*_lrt.txt")
plot_list = list()
plot_names = list()
counter <- 1
for (var in 1:length(Files)){
# 5% cutoff 
setwd(path_to_assoc_files)
tb <- read_delim(Files[var],delim="\t")
colnames(tb)[1] <- "CHR"
colnames(tb)[2] <- "BP"
tb$SNP <- seq(1,length(tb$CHR))
chr <- str_split_fixed(tb$CHR,"chr",2)
chr <- chr[,2]
chr <- as.double(chr)
tb$CHR <- chr
bfc = 0.05/nrow(tb)
# Check for 0s in the LRT_Pval
if (nrow(tb[tb$LRT_Pval==0,])!= 0){
  tb[tb$LRT_Pval==0,]$LRT_Pval <- 1e-100
}
name.file <- Files[var]
name.file <- strsplit(name.file,"_covar2_filtered_lrt.txt")
name.file <- unlist(name.file)
name.file <- paste(name.file,"_min5.png",sep="")
setwd(path_to_save)
png(name.file,width=12,height=5,units='in',res=300)
manhattan(tb, chr="CHR", bp="BP", snp="SNP", p="LRT_Pval", suggestiveline = FALSE,genomewideline = -log10(bfc), chrlabs = as.character(c(1:20,22,23)), col = c("blue4", "green3"), cex = 2, cex.lab = 2, cex.axis = 1.5)
dev.off()
print(paste("Processing ",Files[var],"5% ...",sep=""))

# 10% cutoff 
tb.minmaf10 <- tb[tb$Frequency >= 0.1,]
name.file <- Files[var]
name.file <- strsplit(name.file,"_covar2_filtered_lrt.txt")
name.file <- unlist(name.file)
name.file <- paste(name.file,"_min10.png",sep="")
png(name.file,width=12,height=5,units='in',res=300)
manhattan(tb.minmaf10, chr="CHR", bp="BP", snp="SNP", p="LRT_Pval", suggestiveline = FALSE,genomewideline = -log10(bfc), chrlabs = as.character(c(1:20,22,23)), col = c("blue4", "green3"), cex = 2, cex.lab = 2, cex.axis = 1.5)
dev.off()
print(paste("Processing ",Files[var],"10% ...",sep=""))
}
