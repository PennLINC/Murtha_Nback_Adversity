export FSLOUTPUTTYPE=NIFTI_GZ
subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo

#create an inverse version to capture/threshold negative results
fslmaths $subjectdir/zstat5.nii.gz -mul -1 $subjectdir/inverse_zstat5.nii.gz

mkdir $subjectdir/easythresh2
cd $subjectdir/easythresh2

#threshold the main zstat image
easythresh ../zstat5.nii.gz ../mask.nii.gz 3.09 0.05 /cbica/projects/Kristin_CBF/nback_adversity/pnc_template_brain_2mm.nii.gz zstat5_309_05
easythresh ../inverse_zstat5.nii.gz ../mask.nii.gz 3.09 0.05 /cbica/projects/Kristin_CBF/nback_adversity/pnc_template_brain_2mm.nii.gz inverse_zstat5_309_05

