# mediation inputs take 2

require('caret')
set.seed(1234)

#reading in the model data (bblid, demographics, SES + DPRIME) 
setwd('~/Desktop/nback_adversity/final_code')
model<- read.csv('model.csv')

library(ANTsR)
library(dplyr)
library( devtools )

#reading in the imaging data (4D time series of all 2b0b contrast maps, in order of BBLID) and mask
mnifilename<-getANTsRData("mni")
img<-antsImageRead('4Dnback_main_model_contrast.nii')
mask<- antsImageRead('n1601_NbackCoverageMask_20170427.nii')

#creating an imaging matrix
mat <- timeseries2matrix( img , mask )

#saving as a dataframe so that we can add the other measures
df<- as.data.frame(mat)
df<- cbind(model, df)

sample_1_index <- createDataPartition(df$envSES, p = 0.5, list =F,times=1)
sample_1 <- df[sample_1_index,]
sample_2 <- df[-sample_1_index,]

#split data out in the format needed for  the matlab mediation toolbox 
# X  (envSES),  Y (dprime), and M (imaging) variables for each sample

x1<-sample_1[c(7)]
y1<-sample_1[c(8)]
m1<-sample_1[-c(1:8)]
m1<-as.matrix(m1)

x2<-sample_2[c(7)]
y2<-sample_2[c(8)]
m2<-sample_2[-c(1:8)]
m2<-as.matrix(m2)

#write out files

write.table(x1, file='x1.csv', row.names=FALSE, col.names=FALSE)
write.table(y1, file='y1.csv', row.names=FALSE, col.names=FALSE)
write.table(m1, file='m1.csv', row.names=FALSE, col.names=FALSE)

write.table(x2, file='x2.csv', row.names=FALSE, col.names=FALSE)
write.table(y2, file='y2.csv', row.names=FALSE, col.names=FALSE)
write.table(m2, file='m2.csv', row.names=FALSE, col.names=FALSE)

#run PCA to determine initial number of pc's in mediation analysis

library(factoextra)
pca <- prcomp(x = mat1,scale. = T)
fviz_eig(pca)
sum<-summary(pca)

PCAscores <- pca$x
PCAloadings <- pca$rotation
PCAimportance<- sum$importance

