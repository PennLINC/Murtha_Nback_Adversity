export FSLOUTPUTTYPE=NIFTI_GZ
subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo

cd $subjectdir/
mkdir easythresh13
cd easythresh13

#threshold in PNC space with higher cutoff
easythresh ../zstat5.nii.gz ../mask.nii.gz 4.0 0.05 /cbica/projects/Kristin_CBF/nback_adversity/pnc_template_brain_2mm.nii.gz zstat5_4_05

#transform into MNI
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh13/thresh_zstat5_4_05.nii.gz  -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n LanczosWindowedSinc -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh13/thresh_MNI.nii.gz
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/mask.nii.gz  -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n NearestNeighbor -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh13/brain_mask_MNI.nii.gz
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh13/cluster_mask_zstat5_4_05.nii.gz   -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n NearestNeighbor -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh13/cluster_mask_MNI.nii.gz

#mask zstat5
3dcalc -a thresh_MNI.nii.gz -b cluster_mask_MNI.nii.gz -expr 'ispositive(b)*a' -prefix masked_thresh_MNI.nii.gz

#clusterize  again with low thresholds in AFNI GUI -- nn-level=3, voxels=22, p-val slide bar at 0.
#re-apply easythresh with lower thresholds, generate coords in  --mm
easythresh masked_thresh_MNI.nii.gz brain_mask_MNI.nii.gz 1.0 1.0 /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/MNI152_T1_2mm_brain.nii.gz zstat5_4_05_MNI --mm

#results save as cluster_zstat5_4_05_MNI.txt, neglect last 3 clusters.
