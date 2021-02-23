setwd('/cbica/projects/Kristin_CBF/nback_adversity/Mediation/Out')

library( devtools )
library(ANTsR)
library(dplyr)

#read in matrices from 2 significant pdm's
pdm1<-read.csv('pdm1p.csv', header=FALSE)
pdm2<-read.csv('pdm2p.csv', header=FALSE)

#re-orient
pdm1<- t(pdm1)
pdm2<- t(pdm2)

##recode 0-values as smallest value (1.110223e-16) to fix holes in resulting z-stat maps
pdm1<-recode(pdm1, `0` = 1.110223e-16)
pdm2<-recode(pdm2, `0` = 1.110223e-16)

#test
#min(pdm1)
#min(pdm2)

#re-create images
mnifilename<-getANTsRData("mni")
mask<- antsImageRead('n1601_NbackCoverageMask_20170427.nii')
pdm_stat_img_1<-makeImage( mask, pdm1 )
pdm_stat_img_2<-makeImage( mask, pdm2)

#write out images
antsImageWrite( pdm_stat_img_1, 'pdm_stat_img_1.nii.gz' )
antsImageWrite( pdm_stat_img_2, 'pdm_stat_img_2.nii.gz' )

#read in test and train pdm statistics, convert them to matrices, and fdr corect 
train_pdm<- read.csv('train_pdms.csv', header=FALSE)
test_pdm<-read.csv('test_pdms.csv', header=FALSE)

train_pdm<-as.matrix
test_pdm<-as.matrix(test_pdm)

train_fdr<-p.adjust(train_pdm, method='fdr')
test_fdr<-p.adjust(test_pdm, method='fdr')

write.csv(train_fdr, 'train_fdr.csv')
write.csv(test_fdr, 'test_fdr.csv')

