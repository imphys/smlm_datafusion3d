%% Initialization
clear all 
close all
clc

path(pathdef)
addpath(genpath('test'))
addpath(genpath('MATLAB'))
addpath(genpath('build/mex/'))      %remove everything from path, except the correct mex files 

%initialize particles (S has two locs, M has 1)
S.points = [0,0,0;1,1,1];
S.sigma = [1 3;1 1];
M.points = [1 -1 1];
M.sigma = [10 1];

%test without rotation (RM=identity matrix) or a random rotation
RM = eye(3); 
% RM = rand(3);


%% Calculations
%this code assumes the new mex-files, where the indexing has been changed
%and the costfunction is normalized with respect to the sigmas. 
%If the old mex-files are used, the values will be different/wrong

%CPU
mex_expdist_cpu(S.points,M.points,S.sigma,M.sigma,RM)                 %should give 0.0742
% 0.0725 is S.sigma not reshaped

%GPU
mex_expdist(S.points,M.points,correct_uncer(S.sigma),M.sigma,RM)   %should give 0.0742
mex_expdist(S.points,M.points,correct_uncer(S.sigma),correct_uncer(M.sigma),correct_uncer(RM))   %should give 0.0742
                %> note that we have to reshape sigmasA
                % on GitLab reshape(sigmasA',size(sigmasA,1),2) is replaces
                % by correct_uncer(sigmasA)

%correct manual normalized costFunction

manualCostFunction(S,M,RM)

%% both particles 2 localizations
S.points = [0,0,0;1,1,1];
S.sigma = [1 3;1 1];
M.points = [1 -1 1; 1 2 3];
M.sigma = [10 1; 3 4];

RM = eye(3); 

mex_expdist(S.points,M.points,correct_uncer(S.sigma),(M.sigma),(RM))   %should give 0.0742
mex_expdist(S.points,M.points,correct_uncer(S.sigma),correct_uncer(M.sigma),correct_uncer(RM))   %should give 0.0742
manualCostFunction(S,M,RM)

%good: 0.1208
%

%% Particle M is passed a mx3 uncertainty matrix
S.points = [0,0,0;1,1,1];
S.sigma = [1 3;1 1];
M.points = [1 -1 1];
M.sigma = reshape(diag([10,10,1])*rotx(32)*roty(14),1,9);

RM = eye(3); 
RM = rand(3,3);

mex_expdist(S.points,M.points,correct_uncer(S.sigma),correct_uncer(M.sigma),correct_uncer(RM))   %should give 0.0742
manualCostFunction(S,M,RM)
% RM does not matter here, since 


