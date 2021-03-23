export FSLOUTPUTTYPE=NIFTI_GZ
subjectdir=/cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo

#create an inverse version to capture/threshold negative results
fslmaths $subjectdir/zstat5.nii.gz -mul -1 $subjectdir/inverse_zstat5.nii.gz

cd $subjectdir/
mkdir easythresh
cd easythresh

#threshold the main zstat image
easythresh ../zstat5.nii.gz ../mask.nii.gz 3.09 0.05 /cbica/projects/Kristin_CBF/nback_adversity/pnc_template_brain_2mm.nii.gz zstat5_309_05
easythresh ../inverse_zstat5.nii.gz ../mask.nii.gz 3.09 0.05 /cbica/projects/Kristin_CBF/nback_adversity/pnc_template_brain_2mm.nii.gz inverse_zstat5_309_05

#now, we want to transform into MNI-space to get MNI coordinates of cluster corrected results
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh/thresh_zstat5_309_05.nii.gz  -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n LanczosWindowedSinc -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh/thresh_MNI.nii.gz
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/mask.nii.gz  -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n NearestNeighbor -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh/brain_mask_MNI.nii.gz
antsApplyTransforms -d 3 -e 3 -i /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh/cluster_mask_zstat5_309_05.nii.gz   -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_0Warp.nii.gz -t /cbica/projects/Kristin_CBF/nback_adversity/PNC_transforms/PNC-MNI_1Affine.mat -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  -n NearestNeighbor -o /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/easythresh/cluster_mask_MNI.nii.gz

#mask the converted thresholded image using cluster mask, so marginal voxels are included
3dcalc -a thresh_MNI.nii.gz -b cluster_mask_MNI.nii.gz -expr 'ispositive(b)*a' -prefix masked_thresh_MNI.nii.gz

#clusterize  again with low thresholds in AFNI GUI -- nn-level=3, voxels=2, p-val slide bar at 0.
#re-apply easythresh with lower thresholds, generate coords in  --mm
easythresh masked_thresh_MNI.nii.gz brain_mask_MNI.nii.gz 1.0 1.0 /cbica/projects/Kristin_CBF/nback_adversity/main_model_flameo/MNI152_T1_2mm_brain.nii.gz zstat5_309_05_MNI --mm

#results saved in cluster_zstat5_309_05_MNI.txt
