#!/bin/bash
#SBATCH -A DURBIN-SL2-CPU
#SBATCH -p skylake-himem
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH -t 05:00:00
#SBATCH
#SBATCH -J ANGSD
#SBATCH -o ANGSD.out
#SBATCH -e ANGSD.err
#SBATCH --mail-type=ALL


cd Codes/R_scripts/ANGSD

module purge
module load R/4.0.3

Rscript ANGSD_scatterv2.R
