clear all; clc
addpath(genpath('/cbica/projects/Kristin_CBF/nback_adversity/GitHub/CanlabCore'))
addpath(genpath('/cbica/projects/Kristin_CBF/nback_adversity/GitHub/MediationToolbox'))

% directory where input data is stored. update to your own directory
inputdir = '/cbica/projects/Kristin_CBF/nback_adversity/Mediation'
% directory where results will be saved data. update to your own directory. if it doesnt exist, it will be created
outputdir = '/cbica/projects/Kristin_CBF/nback_adversity/Mediation/Out/'
if ~exist(outputdir, 'dir')
    mkdir(outputdir)
end
cd(outputdir)

%read in TRAINING data
%X should be a csv file with subjects on rows, where each element is neighborhood SES
X = load(fullfile(inputdir,'x1.csv'));

% Y should be a csv file with subjects on rows, where each element is task performance
Y = load(fullfile(inputdir,'y1.csv'));

% M should be a csv file with subjects on rows and voxels of columns, where each element is brain data (beta values from nback GLM)
M = load(fullfile(inputdir,'m1.csv'));

%Zscore X and Y 
%Y = zscore(Y)
%X = zscore(X)

% Set number of PCs to use here. Determine this number from separate PCA
num_pcs = 10

% set number of PDMs here. By default Im setting them to the same as number of PCs
num_pdms = 10

% reorganize data into a bunch of cell variables (input type required for the multivariateMediation function)
xx = {}; yy = {}; mm = {};
for k = 1:length(Y)
    xx{k} = X(k); % store each subjects value for X in its own cell entry
    yy{k} = Y(k); % store each subjects value for Y in its own cell entry
    mm{k} = M(k,:)'; % store each subjects brain map (M) as a vector in its own cell entry
end
xx = xx'; yy = yy'; mm = mm'; % transpose... lazy code...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copied from Multivariate_Mediation_ExampleScript.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset the seed on matlabs random number generator
rng default
rng(1)

% dimensionality reduction via singular value decomposition (or PCA). No PDMs are estimated here.
pdm = multivariateMediation(xx,yy,mm,'B',num_pcs,'svd','noPDMestimation');

% run initial pdm. This will estimate PDMs up to the number you requested (here, same as number of PCs)
pdm = multivariateMediation(pdm,'nPDM',num_pdms);

% assemble a vector of the |ab| path coefficients
path_ab = zeros(1,num_pdms);
for i = 1:num_pdms
    path_ab(i) = abs(pdm.Theta{i}(5));
end

% redefine the number of PDMs by finding the PDMs that have |ab| path coefficients that are >0 up to 4 decimal places
% this might reduce the number of PDMs from the initial value we set above (on line 26)
% reducing this simply stops us from wasting time assessing significance of PDMs with |ab| path coefficients that are equal to 0
% note, you can just comment this line out and the bootstrapping below will run using the number of PDMs originally specified
num_pdms = find(diff(round(path_ab,4) == 0));

% test for path significance
% stats will store the outputs of boostrapping. The p-values for the various paths are stored in .p
% for example, the p values for the first PDM are stored in stats{1} as a vector. This vector stores p values corresponding to the following order: a, b, c', c, ab
% as such, the p-value for the ab path for the first PDM is stored in stats{1}.p(5)
train_stats = cell(0);
for k = 1:num_pdms
    m = pdm.dat.M_tilde*pdm.dat.Dt*pdm.Wfull{k};
    x = cell2mat(xx);
    y = cell2mat(yy);
    [paths, train_stats{k}] = mediation(x, y, m, 'verbose', 'boottop', 'bootsamples', 1e7, 'hierarchical');
end

train_pdm1_ab=train_stats{1,1}.p(5)
train_pdm2_ab=train_stats{1,2}.p(5)
train_pdm3_ab=train_stats{1,3}.p(5)
train_pdm4_ab=train_stats{1,4}.p(5)
train_pdm5_ab=train_stats{1,5}.p(5)
train_pdm6_ab=train_stats{1,6}.p(5)
train_pdm7_ab=train_stats{1,7}.p(5)
train_pdm8_ab=train_stats{1,8}.p(5)
train_pdm9_ab=train_stats{1,9}.p(5)

train_pdms=[train_pdm1_ab;train_pdm2_ab;train_pdm3_ab;train_pdm4_ab;train_pdm5_ab;train_pdm6_ab;train_pdm7_ab;train_pdm8_ab;train_pdm9_ab]

%save outputs
save(strcat('trainPDMresults.mat'), 'train_pdms', 'train_stats')
save(strcat('pdm.mat'), 'pdm')

%write p values out to a csv
csvwrite('train_pdms.csv', train_pdms)

%TEST on left out sample
%read in TESTING data 
%X should be a csv file with subjects on rows, where each element is neighborhood SES
X2 = load(fullfile(inputdir,'x2.csv'));

% Y should be a csv file with subjects on rows, where each element is task performance
Y2 = load(fullfile(inputdir,'y2.csv'));

% M should be a csv file with subjects on rows and voxels of columns, where each element is brain data (beta values from nback GLM)
M2 = load(fullfile(inputdir,'m2.csv'));

xx = {}; yy = {};
for k = 1:length(Y2)
    xx{k} = X2(k); % store each subjects value for X in its own cell entry
    yy{k} = Y2(k); % store each subjects value for Y in its own cell entry
end
xx2 = xx'; yy2 = yy';

%stat test -- see how training weights apply to new data! use Wfull{k}) and
%imaging data from the test dataset. 
test_stats = cell(0);
for k = 1:num_pdms
    m = M2*pdm.Wfull{k};
    x = cell2mat(xx2);
    y = cell2mat(yy2);
    [paths, test_stats{k}] = mediation(x, y, m, 'verbose', 'boottop', 'bootsamples', 1e7, 'hierarchical');
end


test_pdm1_ab=test_stats{1,1}.p(5)
test_pdm2_ab=test_stats{1,2}.p(5)
test_pdm3_ab=test_stats{1,3}.p(5)
test_pdm4_ab=test_stats{1,4}.p(5)
test_pdm5_ab=test_stats{1,5}.p(5)
test_pdm6_ab=test_stats{1,6}.p(5)
test_pdm7_ab=test_stats{1,7}.p(5)
test_pdm8_ab=test_stats{1,8}.p(5)
test_pdm9_ab=test_stats{1,9}.p(5)

test_pdms=[test_pdm1_ab;test_pdm2_ab;test_pdm3_ab;test_pdm4_ab;test_pdm5_ab;test_pdm6_ab;test_pdm7_ab;test_pdm8_ab;test_pdm9_ab]


% save outputs
save(strcat('testPDMresults.mat'), 'test_pdms', 'test_stats')

%write test p  values out to a csv 
csvwrite('test_pdms.csv', test_pdms)
