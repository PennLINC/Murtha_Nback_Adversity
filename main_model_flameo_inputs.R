##Write out inputs for flameo (adapted from Zizu's script)
setwd("/cbica/projects/Kristin_CBF/nback_adversity/")
library(pracma)
library(unglue)

model<- read.csv('model.csv')
designmat=cbind(ones(length(model$bblid),1),model$ageAtScan1,model$sex,model$nbackRelMeanRMSMotion,model$envSES)

grp=ones(length(model$bblid),1)
contrast=zeros(size(designmat,2))
diag(contrast)=1

dir.create('main_model_inputs')

write.table(designmat,'main_model_inputs/design.txt',sep=' ', quote = FALSE,row.names = FALSE,col.names = FALSE)
write.table(grp,'main_model_inputs/grp.txt',sep=' ', quote = FALSE,row.names = FALSE,col.names = FALSE)
write.table(contrast,'main_model_inputs/contrast.txt',sep=' ', quote = FALSE,row.names = FALSE,col.names = FALSE)
write.table(model$bblid,'main_model_inputs/bblid.txt',sep=' ', quote = FALSE,row.names = FALSE,col.names = FALSE)

##Last set of inputs: lists of contrasts and varcope paths from pmacs directory. 
##Manipulate the names so we can filter by BBLID and only include paths in our sample. 

library(unglue)
contrast<- read.csv('cope.csv', header=FALSE)
contrast<- data.frame(contrast, contrast)

bblid<-unglue_vec(contrast$V1,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}/{y}", var = "y")
bblid<-unglue_vec(bblid,"{x}_{y}", var = "x")
bblid<-as.numeric(bblid)

contrast_2 <- data.frame(bblid, contrast$V1.1)
contrast_3<- filter(contrast_2, bblid %in% sample_bblid)


contrast_3<- arrange(contrast_3, bblid)

write.table(contrast_3$contrast.V1.1, file='main_model_inputs/2b0bcontrast_list.csv', row.names=FALSE, col.names=FALSE)

varcope<- read.csv('varcope.csv', header=FALSE)
varcope<- data.frame(varcope, varcope)

bblid_2<- unglue_vec(varcope$V1, "{x}/{y}", var = "y")
bblid_2<- unglue_vec(bblid_2, '{x}/{y}',var = 'y')
bblid_2<- unglue_vec(bblid_2, '{x}/{y}',var = 'y')
bblid_2<- unglue_vec(bblid_2, '{x}/{y}',var = 'y')
bblid_2<- unglue_vec(bblid_2, '{x}/{y}',var = 'y')
bblid_2<- unglue_vec(bblid_2, '{x}/{y}',var = 'y')
bblid_2<- unglue_vec(bblid_2, '{x}_{y}',var = 'x')
bblid_2<-as.numeric(bblid_2)

varcope_2<- data.frame(bblid_2, varcope$V1.1)
varcope_3<- filter(varcope_2, bblid_2 %in% sample_bblid)
varcope_3<- arrange(varcope_3, bblid_2)

write.table(varcope_3$varcope.V1.1, file='main_model_inputs/2b0bvarcope_list.csv', row.names=FALSE, col.names=FALSE)

##These lists can be used for any flameo that uses the full subset of 1158 participants. 
