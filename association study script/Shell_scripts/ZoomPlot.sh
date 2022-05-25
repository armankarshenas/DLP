#!/bin/bash
#SBATCH -A DURBIN-SL2-CPU
#SBATCH -p skylake-himem
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH -t 04:00:00
#SBATCH
#SBATCH -J plot_zoom0
#SBATCH -o plot_zoom0.out
#SBATCH -e plot_zoom0.err
#SBATCH --mail-type=ALL


cd Codes/Matlab_scripts/GeneAssociation

module purge
module load rhel7/default-peta4 matlab

matlab -nodisplay -nosplash -r "run('ZoomPlot.m'); quit"
