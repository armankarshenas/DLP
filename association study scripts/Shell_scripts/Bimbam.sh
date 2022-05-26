#!/bin/bash
#SBATCH -A DURBIN-SL2-CPU
#SBATCH -p skylake-himem
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH -t 05:00:00
#SBATCH
#SBATCH -J BimbamFile
#SBATCH -o BimbamFile.out
#SBATCH -e BimbamFile.err
#SBATCH --mail-type=ALL


cd Codes/Matlab_scripts/GeneAssociation

module purge
module load rhel7/default-peta4 matlab

matlab -nodisplay -nosplash -r "run('BimbamFileAnalysis.m'); quit"
