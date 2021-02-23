#Sample Selection
#Kristin A. Murtha

setwd('/cbica/projects/Kristin_CBF/nback_adversity/raw_data')

library(dplyr)
'%ni%' <- Negate('%in%')

#Read in files saved from N1601 PNC DataFreeze, including QA, health exclusions, in-scanner behavioral data, demographics, and measures of interest on trauma and SES 

n1601_QA<- read.csv('n1601_NBACKQAData_20181001.csv')
health_exclusions<-read.csv('n1601_health_20170421.csv')
n1601_nback<- read.csv('n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv')
n1601_demos<- read.csv('n1601_demographics_go1_20161212.csv')
n1601_trauma<- read.csv('n1601_bblids_scanids_trauma_SES.csv')

#sample selection
#first, exclude p's who didn't complete task (column #3 'nbackZerobackNrExclude'=0')
sample<- filter(n1601_nback, nbackZerobackNrExclude == '0')

#next, exclude for health conditions that can impact brain function
#create a list of BBLID's who are excluded, and filter sample by those ID's
exclude_health<- filter(health_exclusions, healthExcludev2 == '1')
exclude_health_bbl<- exclude_health[,1]

sample<- filter(sample, bblid %ni% exclude_health_bbl)

#next, exclude for image quality 
#create a list of BBLID's who failed QA measures, and filter sample by those ID's
exclude_qa<- filter(n1601_QA, nbackExcludeVoxelwise == '1')
exclude_qa_bbl<- exclude_qa[,1]

sample<- filter(sample, bblid %ni% exclude_qa_bbl)

#finally, exclude for incomplete trauma data
#create a ilst of BBLID's missing trauma or SES data, and filter sample by those ID's
include_tramua<- na.omit(n1601_trauma)
include_trauma_bbl<- include_tramua[,1]

sample<- filter(sample, bblid %in% include_trauma_bbl)
sample<- arrange(sample, bblid)
sample_bblid<- sample[,1]

write.table(sample_bblid, file='sample_bblid.csv', row.names=FALSE, col.names=FALSE)

#filter each measure by list of sample ID's
sample_qa<- filter(n1601_QA, bblid %in% sample_bblid)
sample_nback<- filter(n1601_nback, bblid %in% sample_bblid)
sample_demos<- filter(n1601_demos, bblid %in% sample_bblid)
sample_trauma<- filter(n1601_trauma, bblid %in% sample_bblid)

#write.csv(sample_qa, file= "sample_qa.csv", row.names=FALSE)
#write.csv(sample_nback, file= 'sample_nback.csv', row.names=FALSE)
#write.csv(sample_demos, file= 'sample_demos.csv', row.names=FALSE)
#write.csv(sample_trauma, file= 'sample_trauma.csv', row.names=FALSE)


#Now, merge all relevant measures into 1 model CSV

#First, create a binary race variable, where white=0 and non-white=1
sample_demos$race3<- sample_demos$race2
sample_demos$race3<-recode(sample_demos$race3, '3'=2, '2'=2, '1'=1)
sample_demos$race3<- recode(sample_demos$race3, '1'=0, '2'=1)

#Then select the variables of interest to be merged into our model 
age_sex_race<- c("bblid", "ageAtScan1","sex", "race3")
model_demos<- sample_demos[age_sex_race]

#Next, do the same with motion measures
motion<- c("bblid", "nbackRelMeanRMSMotion")
model_qa<- sample_qa[motion]

#And with behavioral Data
dprime<- c("bblid", "nbackBehAllDprime")
model_nback<- sample_nback[dprime]

#And with trauma 
cumulative_stress_load_envses<-c("bblid", "Cummulative_Stress_Load_No_Rape","envSES")
model_trauma<- sample_trauma[cumulative_stress_load_envses]

#Create a model data  frame, starting with sample BBLID's
model<- data.frame(sample_bblid)
model<- model %>% rename(bblid = sample_bblid) 

#Now merge in additional fields and write out a CSV
model<-  Reduce(function(x,y)  merge(x, y, by = 'bblid', all.x=TRUE,all.y=TRUE), list(model, model_demos, model_qa, model_trauma, model_nback))

write.csv(model, file='../model.csv', row.names=FALSE)

