<br>
<br>
# Association of Neighborhood Socioeconomic status and Working Memory Activation
*Prior work has shown that environmental adversity affects cognitive development. However, it is unclear how these challenges impact brain systems, like the executive system, which underlie cognition. The current study examined the association of neighborhood socioeconomic status (SES) with executive system activation during a working memory task in the Philadelphia Neurodevelopmental Cohort.*


### Project Lead
Kristin A. Murtha

### Faculty Leads
Theodore D. Satterthwaite

### Analytic Replicator
Bart Larsen

### Collaborators
Bart Larsen, Adam Pines, Linden Parkes, Tyler M. Moore, Azeez Adebimpe, Aaron Alexander-Bloch, Monica E. Calkins, Allyson Mackey, David Roalf, J. Cobb Scott, Daniel Wolf, Ruben Gur, Raquel Gur, Ran Barzilay, Theodore Satterthwaite

### Project Start Date
May 2020

### Current Project Status
Data Analysis and Documentation

### Datasets
810336 - PNC

### Github Repository
<https://github.com/PennLINC/Murtha_Nback_Adversity>

### Path to Data on Filesystem
/cbica/projects/Kristin_CBF/nback_adversity

### Publication DOI
N/A

### Conference Presentations
- Poster presentation at the FLUX Virtual Congress, September 2020 *Association between Neighborhood Socioeconomic Status and Executive System Activation in Youth*

<br>
<br>
# CODE DOCUMENTATION
The steps below detail how to replicate all aspects of statistical analysis for this project, from sample selection to high dimensional mediation.

### Image Preprocessing
1. Imaging and clinical data was pulled from the n1601 PNC data freeze. Image pre-processing is described in [/Satterthwaite et al., 2013](https://www.jneurosci.org/content/33/41/16249).
2. Cope & and varcope maps, as well as data on motion QA, medical exclusions, in-scanner behavior and  clinical measures are included in the CUBIC directory.

### Sample selection + Organization
1. Execute [/sample_selection_and_model_merge.R](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/sample_selection_and_model_merge.R) to filter out participants who failed imaging QA and those with medical co-morbidities or incomplete data.
2. Execute [/main_model_flameo_inputs.R](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/main_model_flameo_inputs.R) to organize the data into the inputs needed to run the main mass univariate voxelwise  analysis.  
    > This script generates 4 .txt files (`grp.txt`, `bblid.txt`, `contrast.txt`, and design.txt) and 2 csv files containing file  paths to the cope and varcope  maps of each included subject. The .txt files will need to be converted into the following file formats, using FSL's `Text2Vest` command: `grp.grp`, `contrast.con`, and `design.mat`. These inputs are stored in a directory called `main_model_flameo_inputs`.>

### Mass-univariate voxelwise analysis & cluster correction
1. Run [/run_flameo.sh](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/run_flameo.sh) to execute the mass-univariate voxelwise analysis, examining association between environmental SES and changes in brain activation in the 2-back>0-back maps, with age, sex, and motion included as covariates.
    > This script creates 4D time-series images of all 2b<0b contrast and varcope images, and executes the main analysis in runmode `flame1`. Output will be stored in a directory called `main_model_flameo`. The SES result is contained in `zstat5.nii.gz`.
2. Run [/flameo_easythresh.sh](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/flameo_easythresh.sh) to  cluster correct with voxel height > 3.09 and cluster probability p<0.05.

### High dimensional Mediation Analysis  
1. Execute [/mediation_inputs.R](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/mediation_inputs.R) to create the inputs needed for our high dimensional mediation analysis.
    > This script transforms the  4D 2b>0b contrast image into a matrix, then  splits that, along with participant's dprime and  SES  scores into 2 stratified samples for testing and training analyses  using CARET. This script will also perform an initial PCA  of the imaging data to guide the mediation.
2.  Run [/run_mediation.m](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/run_mediation.m) to execute the high dimensional mediation analysis, as documented in [/this repository](https://github.com/canlab/MediationToolbox/tree/master/PDM_toolbox). Use command `qsub -l h_vmem=200G,s_vmem=180G qsub_matlab.sh run_mediation.m` The submit script is found [/here](http://github.com/LINK!).
    > This matlab script executes an initial PCA, derives # of PMD's  from the training dataset + performs significance  testing and bootstrapping. The mediators derived from the training data are then applied to the testing dataset, to test for generalizability. All results are saved in .mat files  `testPDMresults.mat` and `trainPDMresults.mat`. The p-values for testing and training are saved separately in .csv files for FDR correction in R.
3. Run [/mediation_boot](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/mediation_boot.m) to execute bootstrapping on the voxel-wise weights associated with each PDM. This can take a while! Use command `qsub -l h_vmem=200G,s_vmem=180G qsub_matlab.sh run_mediation.m` The submit script is found [/here](http://github.com/LINK!). Results are saved as `pdm1p` and `pdm2p` in both .mat and .csv files.

### Mediation results image reconstruction + correction
1. Execute [/recreate_images.R](https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/recreate_images.R) to reconstruct the p-value matrices as images, and FDR correct the p-values associated with the PDM's relationship with test and train data. These statistics will be reported in the manuscript.
2. Run [mediation_easythresh.sh]((https://github.com/PennLINC/Murtha_Nback_Adversity/blob/main/mediation_easythresh.sh) to cluster correct the PDM images in the same way as we corrected the original z-stat images.
    > This script uses fslmath's `ptoz` command to convert the p-values output by matlab to zcores that are interpretable by the easythresh, and executes the cluster correction with voxel height > 3.09 and cluster probability p<0.05.
