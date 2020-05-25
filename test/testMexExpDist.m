%% Initialization
clear all 
close all
clc

path(pathdef)
addpath(genpath('test'))
addpath(genpath('MATLAB'))
addpath(genpath('build/mex/'))      %remove everything from path, except the correct mex files 

%initialize particles (S and M have two locs)
S.points = [0,0,0;1,1,1];
S.sigma = [1 3;1 1];
M.points = [1 -1 1; 1 2 3];
M.sigma = [10 1; 3 4];

%test without rotation (RM=identity matrix) or a random rotation
RM = eye(3); 
% RM = rand(3);


%% Calculations
%this code assumes the new mex-files, where the indexing has been changed
%and the costfunction is normalized with respect to the sigmas. 
%If the old mex-files are used, the values will be different/wrong

%CPU
mex_expdist_cpu(S.points,M.points,S.sigma,M.sigma,RM)                 %should give 0.1208

%GPU
mex_expdist(S.points,M.points,correct_uncer(S.sigma),M.sigma,RM)   %should give 0.1208
                %> note that we have to reshape sigmasA
                % on GitLab reshape(sigmasA',size(sigmasA,1),2) is replaces
                % by correct_uncer(sigmasA)

%manua
manualCostFunction(S,M,RM)


%% Particle M is passed a mx9 uncertainty matrix (M has 2 locs) 
S.points = [0,0,0];%;1,1,1];
S.sigma = [1 3];%;1 1];
M.points = [1 -1 1; 1 2 3];
M.sigma = [reshape(diag([10,10,1])*rotx(32)*roty(14)*rotz(11),1,9); reshape(diag([3,3,4])*rotx(123)*roty(110)*rotz(13),1,9)] ;

RM = eye(3);
% RM = rand(3,3);     %RM does nothing when M.sigma is mx9

mex_expdist(S.points,M.points,correct_uncer(S.sigma),M.sigma,RM)        %wrong, 
mex_expdist(S.points,M.points,correct_uncer(S.sigma),correct_uncer(M.sigma),RM)  %is good right now
manualCostFunction(S,M,RM)      %0.3133



