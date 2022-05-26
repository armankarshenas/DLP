# This script has been written to filter the ANGSD files 

# Load the required packages 
library(data.table)
library(readr)
library(ggplot2)
# set the paths and find the files
path_to_assoc_files <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/afra_zebra/gwas/ct/angsd_association"
path_to_save <- "~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/ak2272/Results/Figures/ANGSD/QQplots-pvalue"
setwd(path_to_assoc_files)
Files <- list.files(path = ".",pattern = "*.lrt0.gz")

# Decompress the files and import them 
plot_list <- list()
plot_names <- list() 
counter = 1
for (f in 1:length(Files)){
  setwd(path_to_assoc_files)
  dt <- fread(Files[f])
  # Removing the low coverage sites 
  dt <- dt[dt$LRT > -800,]
  # Now computing the LRT_Pval
  LRT_Pval <- pchisq(dt$LRT,df=1,lower.tail = FALSE)
  dt$LRT_Pval <- LRT_Pval
  print(Files[f])
  # Name for the txt files
  name.file <- Files[f]
  name.file <- strsplit(name.file,".lrt0.gz")
  name.file <- unlist(name.file)
  name.file <- paste(name.file,"_filtered_lrt.txt",sep = "")
  #write.table(dt,name.file,sep = "\t")
  # Name editing 
  name.file <- Files[f]
  name.file <- strsplit(name.file,".lrt0.gz")
  name.file <- unlist(name.file)
  name.file <- paste(name.file,".tiff",sep = "")
  plot_names[[counter]] <- name.file
  setwd(path_to_save)
  x <- sort(-log10(runif(n=nrow(dt))))
  y <- unlist(dt[,9])
  y <- sort(-log10(y))
  D <- data.frame(x,y)
  name.plot <- strsplit(name.file,"_covar2.tiff")
  name.plot <- unlist(name.plot)
  #tiff(file=name.file,width=10,height = 4,units = 'in',res=300)
  plot_list[[counter]]<-ggplot(D,aes(x=x,y=y)) + geom_point() + geom_abline(D,mapping=aes(slope=1,intercept=0),col="red",lty=2) + labs(x="-log10(unif[0,1])") + labs(y="-log10(obs pvalues)") + labs(title = paste(name.plot,"-min af of 5%",sep = ""))
  counter <- counter +1
  # minmaf10% plots 
  dt <- dt[dt$Frequency >= 0.10,]
  name.file <- Files[f]
  name.file <- strsplit(name.file,".lrt0.gz")
  name.file <- unlist(name.file)
  name.file <- paste(name.file,"_minmaf10.tiff",sep = "")
  plot_names[[counter]] <- name.file
  x <- sort(-log10(runif(n=nrow(dt))))
  y <- unlist(dt[,9])
  y <- sort(-log10(y))
  D <- data.frame(x,y)
  name.plot <- strsplit(name.file,"_covar2_minmaf10.tiff")
  name.plot <- unlist(name.plot)
  #tiff(file=name.file,width = 10,height = 4,units = 'in',res = 300)
  plot_list[[counter]] <- ggplot(D,aes(x=x,y=y)) + geom_point() + geom_abline(D,mapping=aes(slope=1,intercept=0),col="red",lty=2) + labs(x="-log10(unif[0,1])") + labs(y="-log10(obs pvalues)") + labs(title = paste(name.plot,"-min af of 10%",sep = ""))
counter <- counter +1
}
setwd(path_to_save)
# Saving the plots 
for (i in 1:counter){
  tiff(plot_names[[i]])
  print(plot_list[[i]])
  dev.off()
}
