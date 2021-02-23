export FSLOUTPUTTYPE=NIFTI_GZ
subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/Mediation/Out
maindir=/cbica/projects/Kristin_CBF/nback_adversity

#transform the uncorrected p-values to z-scores
fslmaths $subjectdir/pdm_stat_img_1.nii.gz -ptoz pdm1_zstat.nii.gz 
fslmaths $subjectdir/pdm_stat_img_2.nii.gz -ptoz pdm2_zstat.nii.gz

mkdir $subjectdir/easythresh2
cd $subjectdir/easythresh2

#threshold the main zstat image
easythresh $subjectdir/pdm1_zstat.nii.gz $maindir/n1601_NbackCoverageMask_20170427.nii.gz 3.09 0.05 $maindir/pnc_template_brain_2mm.nii.gz pdm1_zstat_309_05
easythresh $subjectdir/pdm2_zstat.nii.gz $maindir/n1601_NbackCoverageMask_20170427.nii.gz 3.09 0.05 $maindir/pnc_template_brain_2mm.nii.gz pdm2_zstat_309_05


