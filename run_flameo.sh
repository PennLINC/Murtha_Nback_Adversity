export FSLOUTPUTTYPE=NIFTI_GZ

bblid=$(cat /cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/bblid.txt)
 subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/
nback_contrast=/cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/2b0bcontrast_list.csv
nback_varcope=/cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/2b0bvarcope_list.csv
rm -rf  $nback_contrast
rm -rf  $nback_varcope

for i in $bblid; do
 img=$subjectdir/n1601_voxelwiseMaps_cope/${i}_*_contrast4_2back0backStd.nii.gz*
 echo $img >> $nback_contrast
done
rm -rf $subjectdir/4Dnback_main_model_contrast.nii.gz
fslmerge -t $subjectdir/4Dnback_main_model_contrast.nii.gz $(cat $nback_contrast )

for i in $bblid; do
 img=$subjectdir/n1601_voxelwiseMaps_varcope/${i}_*_varcope4_2back0backStd.nii.gz*
 echo $img >> $nback_varcope
done
rm -rf $subjectdir/4Dnback_main_model_varcope.nii.gz
fslmerge -t $subjectdir/4Dnback_main_model_varcope.nii.gz $(cat $nback_varcope )


export FSLOUTPUTTYPE=NIFTI_GZ
subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/
mask=/cbica/projects/Kristin_CBF/nback_adversity/n1601_NbackCoverageMask_20170427.nii.gz
design=/cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/design.mat
contrast=/cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/contrast.con
group=/cbica/projects/Kristin_CBF/nback_adversity/main_model_inputs/grp.grp

flameo --cope=$subjectdir/4Dnback_main_model_contrast.nii.gz --varcope=$subjectdir/4Dnback_main_model_varcope.nii.gz --mask=$mask  --dm=${design} --tc=${contrast} --cs=${group} --runmode=flame1 --ld=${subjectdir}/main_model_flameo

