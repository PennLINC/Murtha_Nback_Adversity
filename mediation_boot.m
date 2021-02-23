clear all; clc
addpath(genpath('/cbica/projects/Kristin_CBF/software/CanlabCore'))
addpath(genpath('/Users/krmurtha/Downloads/catstruct'))
addpath(genpath('/Users/krmurtha/Documents/GitHub/fdr_bh'))
addpath(genpath('/cbica/projects/Kristin_CBF/software/MediationToolbox'))

% directory where input data is stored. update to your own directory
inputdir = '/cbica/projects/Kristin_CBF/nback_adversity/Mediation/Out'
% directory where results will be saved data. update to your own directory. if it doesnt exist, it will be created
outputdir = '/cbica/projects/Kristin_CBF/nback_adversity/Mediation/Out'
if ~exist(outputdir, 'dir')
    mkdir(outputdir)
end
cd(outputdir)

load('testPDMresults.mat', 'pdm')

pdm1 = multivariateMediation(pdm,'noPDMestimation','bootPDM',1,'Bsamp',1e4);
pdm2 = multivariateMediation(pdm,'noPDMestimation','bootPDM',2,'Bsamp',1e4);

pdm1p=pdm1.boot.p
pdm2p=pdm2.boot.p

save('pdm1p.mat', 'pdm1p')
save('pdm2p.mat', 'pdm2p') 

writecell(pdm1p, 'pdm1p.csv')
writecell(pdm2p, 'pdm2p.csv')
