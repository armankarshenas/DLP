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

Most CT image datasets are generated as stacks of two dimensional images in the Anteriori-Posterior (AP) axis of the body, and are commonly encoded as 16-bit wide TIFF images. These image stacks are often too large to be loaded on the RAM as a three dimensional tensor, and create substantial memory constraints. Here, we therefore, have implemented scripts that can be used to compress and denoise the images while keeping the information content intact. The deep learning models trained and used are also based on two dimensional projections in order to minimise computational complexity, and to prevent overfitting. 

Each of the following scripts starts with a specification section that should be editted in order for the package to have the correct paths to image datasets and the meta data. 

### Pre processing 
---
Please use the following scripts to pre-process the images as needed before training the network: 

1. To compress the images please run the following scripts in the order they have been represented here. The first script generates a bit profile that can be used by the second script to decide the number of bits that can be truncated. 
		
		Randomness.m
		Compress.m
2. The following scripts can be used to align the centre of images, rotate them, converts TIFFs to JPEGs, reverse the order of images in the image stack, and downsample images using a tunable Gaussian kernel respectively. 

		Centre.m
		Rotate.m
		JPEGCovert.m
		ReverseOrder.m
		Downsample.m
3. Once images are pre-processed, the following script should be used to generate image stacks in the other two projections: namely Left-Rigth (LR) and Dorsal-Ventral (DV). 

		Orientation.m
		
### Resnet50-SVM training 
---