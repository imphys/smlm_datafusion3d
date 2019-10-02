%%

%% 
close all
clear all

% add the required directory to path
path_matlab = genpath('build/mex/');
addpath(path_matlab)

path_matlab = genpath('build/figtree/src/mex/');
addpath(path_matlab)

path_matlab = genpath('MATLAB');
addpath(path_matlab)

% CPU/GPU settings (CPU = 0, GPU = 1)
USE_GPU_GAUSSTRANSFORM = 1;
USE_GPU_EXPDIST = 1;

% load dataset stored in data directory
filename = 'data.mat';
load(['data/' filename]);

N = 10;     % choose N particles
if N > numel(particles)
    N = numel(particles);
end
subParticles = cell(1,N);
ptCloudTformed = cell(1,N);

for i=1:N
    subParticles{1,i}.points = particles{1,i}.coords(:,1:3);
    idxZ = find(subParticles{1,i}.points(:,3) > 1 | subParticles{1,i}.points(:,3) < -1);
    subParticles{1,i}.points(idxZ,:) = [];
    subParticles{1,i}.sigma = [particles{1,i}.coords(:,5).^2 particles{1,i}.coords(:,10).^2];
    subParticles{1,i}.sigma(idxZ,:) = [];
    ptCloudTformed{i} = pointCloud(subParticles{1,i}.points);
end

%% STEP 1
% all-to-all registration
disp('all2all registration started!');
[RR, I] = all2all3D(subParticles, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

%% STEP 2 
% 2-1 Lie-algebraic averaging
disp('Lie-algebraic averaging started!');
% average relative rotations+translation (RR) to get the absolute ones (Mest)
Mest = MeanSE3Graph(RR, I);

% 2-2 registration consistency check
[RM_new, I_new] = consistencyCheck(Mest, RR, I, N);

% 2-3 second Lie-algebraic averaging
disp('2nd Lie-algebraic averaging started!');
[M_new] = MeanSE3Graph(RM_new,I_new);

% 2-4 make the first data-driven template
[initAlignedParticles, sup] = makeTemplate(M_new, ptCloudTformed, subParticles, N);

%% STEP 3
% bootstrapping with imposing symmetry prior knowledge
USE_SYMMETRY = 1;   % flag for imposing symmetry prio knowledge
M1 = [];            % not implemented
iter = 5;           % number of iterations
[superParticleWithPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, USE_SYMMETRY, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

%% STEP 3
% bootstrapping without imposing symmetry prior knowledge
USE_SYMMETRY = 0;   % flag for imposing symmetry prio knowledge
M1=[];              % not implemented
iter = 5;           % number of iterations
[superParticleWithoutPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, USE_SYMMETRY, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

%% Visualize the results
visualizeCloud3D(superParticleWithoutPK{1,5},0.05, 1);
visualizeCloud3D(superParticleWithPK{1,5},0.05, 1);