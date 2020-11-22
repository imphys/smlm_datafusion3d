%%
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Hamidreza Heydarian, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0

%% 
close all
clear all

% add the required dir to path. Choose the right code block for your OS
% for linux
path_mex_matlab1 = genpath('build/mex/');
path_mex_matlab2 = genpath('build/figtree/src/mex/');
path_matlab = genpath('MATLAB');

% for windows
% path_mex_matlab1 = genpath('build\Debug\mex');
% path_mex_matlab2 = genpath('build\figtree\Debug');
% path_matlab = genpath('MATLAB');

addpath(path_mex_matlab1)
addpath(path_mex_matlab2)
addpath(path_matlab)

% CPU/GPU settings (CPU = 0, GPU = 1)
USE_GPU_GAUSSTRANSFORM = 1;
USE_GPU_EXPDIST = 1;

% load dataset stored in data directory
filename = 'nup_data.mat';
load(['data/' filename]);

N = 100;     % choose N particles
if N > numel(particles)
    N = numel(particles);
end
subParticles = cell(1,N);

for i=1:N
    subParticles{1,i}.points = particles{1,i}.coords(:,1:3);
    idxZ = find(subParticles{1,i}.points(:,3) > 1 | subParticles{1,i}.points(:,3) < -1);
    subParticles{1,i}.points(idxZ,:) = [];
    subParticles{1,i}.sigma = [particles{1,i}.coords(:,5).^2 particles{1,i}.coords(:,10).^2];
    subParticles{1,i}.sigma(idxZ,:) = [];
end

%% STEP 1
% all-to-all registration

% when the particles have a prefered orientation, like NPCs that lie in the
% cell membrane, it is recommanded to do in-plane initialization to save 
% computational time for example initAng = 1 (see pairFitting3D.m line 68). 
initAng = 'grid_72.qua';

% For NPC particle scale = 0.1 (10 nm) is the optimal choice. In other
% cases, it is recommanded to use the scale_sweep() function to find the
% optimal value. This needs to be done once for a structure (see Online
% Methods and demo2.m)
scale = 0.1;    % in camera pixel unit (corresponds to 10 nm in physical unit)

disp('all2all registration started!');
[RR, I] = all2all3D(subParticles, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
disp('all2all registration finished!');
%% STEP 2
% iterations of:
% 2-1 lie-algebra averaging of relative transformation
% 2-2 consistency check
% 2-3 constructing the data-driven template

nIterations = 5;           % number of lie-algebra avg and consistency check
                            % iterations
flagVisualizeSijHist = 1;   % show S_ij histogram (boolean) 
threshold = 0.5;            % consistency check threshold.
[initAlignedParticles, sup] = relative2absolute(subParticles, RR, I, N, ...
                                                nIterations, threshold, 1);

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
visualizeSMLM3D(superParticleWithoutPK{1,5},0.05, 1);
% visualizeCloud3D(superParticleWithPK{1,5},0.05, 1);