# DLP (Deep Learning Phenotyper) package  
---
The DLP package phenotypes morphological variation of vertebrates using deep learning and CT scan image datasets. The model uses pre-trained Resnet50 along with a tunable Fully Connected (FC) layer and a linear SVM that can be customised based on the application at hand. This README file briefly introduces the scripts and how they can be used. For a more comprehensive guideline, please see the comments in each of the scripts.

## Repository content
Description of the directories in this repositories are provided below:

1. **association study scripts** - This directory contains Shell, R and Matlab scripts that were used to run and process outputs of Genome Wide Association Studies (GWAS).  
2. **labelling** - This directory contains a tutorial video and further documentation on how labelling of CT datasets should be done before the DLP package can be used.  
3. **scripts** - This directory contains all the Matlab scripts that were implemented to 1. pre-process 2. classify and 3. segment the CT image datasets in order to generate measurements that can quantify the morphology. The scripts directory itself branches to three sub-directories each contaning scripts for the tasks mentioned above. **Note that Matlab scripts with an _ are functions that are called in scripts**. 

## How to install the DLP package 

The DLP package can be easily installed by just cloning the repository on to your local host. You can run the following command to clone this repository in the current directory of your local computer: 

	 git clone https://github.com/armankarshenas/dlp


## How to use the DLP package 

