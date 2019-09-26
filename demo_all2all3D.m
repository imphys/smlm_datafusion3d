%%

%% 
close all
clear all

% add the required directory to path
path_matlab = genpath('MATLAB');
addpath(path_matlab)

% CPU/GPU settings (CPU = 0, GPU = 1)
USE_GPU_GAUSSTRANSFORM = 1;
USE_GPU_EXPDIST = 1;

% load dataset stored in data directory
filename = 'new_3D_NUP107_ph5000_dol75_tr20nm_3D_paint_ang3D_70_10';
load(['data/' filename]);

N = 10;     % choose N particles
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

% convert localization data to MATLAB pointCloud object
ptCloudTformed = cell{1,N};
for i=1:N
        ptCloudTformed{i} = pointCloud(subParticles{1,i}.points);
end


% filling out the all2all registration matrix (result)
result = cell(N-1,N);
for i=1:N-1
    for j=i+1:N
        
        param = all2all3Dn(ptCloudTformed{i}.Location, ptCloudTformed{j}.Location, ...
                           subParticles{1,i}.sigma, subParticles{1,j}.sigma, 1, 1, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

        result{i,j}.parameter = param;
        result{i,j}.id = [i; j];       
        
    end    
    disp(['row ' num2str(i) ' is done.'])    
end

% convert quaternion to matrix representation (SE3)
RR = zeros(4,4,N*(N-1)/2);  % relative transformation (rotation+translation)
I = zeros(2,N*(N-1)/2);     % connectivity matrix
k = 1;
for i=1:N-1
    for j=i+1:N
        q = [result{i,j}.parameter(4) result{i,j}.parameter(1) ...
             result{i,j}.parameter(2) result{i,j}.parameter(3)];
         
        % RR holds the registration parameters of size 4x4xN(N-1)/2 
        RR(1:3,1:3,k) = q2R(q);
        RR(1:3,4,k) = [result{i,j}.parameter(5); result{i,j}.parameter(6); result{i,j}.parameter(7)];
        RR(4,4,k) = 1;
        RR(4,1:3) = 0;
        
        % I holds the connectivity of pairs of size 2xN(N-1)/2
        I(:,k)=result{i,j}.id;
        k=k+1;        
    end
end

%% STEP 2-1 
% Lie-algebraic averaging

disp('Lie-algebraic averaging started!');
% average relative rotations+translation (RR) to get the absolute ones (Mest)
Mest = MeanSE3Graph(RR, I);

%% STEP 2-2 
% registration consistency check

% relative all2all rotation and translation after averaging
relR = zeros(3,3,N*(N-1)/2);
kk = 1;
for i=1:N-1
    for j=i+1:N
        relR(:,:,kk) = Mest(1:3,1:3,j)'*Mest(1:3,1:3,i);
        kk = kk+1;
    end
end

for i=1:size(RR,3)
   d(i) =  distSE3(RR(:,:,i),relR(:,:,i));
end

error_idx = find(abs(d)>2);          % threshold, should be automated

RM_new = RR;                         % new relative transformation
I_new = I;                           % new connectivity matrix
RM_new(:,:,error_idx) = [];          % exclude outliers                        
I_new(:,error_idx) = [];             % exclude outliers
%% STEP 2-3
% second Lie-algebraic averaging
[M_new] = MeanSE3Graph(RM_new,I_new);
disp('2nd rotation averaging done!');

%% STEP 2-4 
% apply the absolute registration parameters to particles to make the data-
% driven template

ptCloudestTformed = cell(1,N);      % first aligned pointClouds
initAlignedParticles = cell(1,N);   % first aligned particles
sup =[];                            % data-driven template
for i=1:N       
    
    estA = eye(4);
    estA(1:3,1:3) = M_new(1:3,1:3,i); 
    estA(4,:) = M_new(:,4,i)';
    estTform = affine3d(estA);
    
    % transform each point cloud
    ptCloudestTformed{i} = pctransform2(ptCloudTformed{i}, invert(estTform));
    
    % initial aligned particles for bootstrapping
    initAlignedParticles{1,i}.points = ptCloudestTformed{i}.Location;
    initAlignedParticles{1,i}.sigma = subParticles{1,i}.sigma;    
    
    % stack all registered particles
    sup = [sup; ptCloudestTformed{i}.Location];
    
end
%% STEP 3
% bootstrapping with imposing prior knowledge

USE_SYMMETRY = 1;   % flag for imposing symmetry prio knowledge
M1 = [];            % not implemented
iter = 4;           % number of iterations
[superParticleWithPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, USE_SYMMETRY, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

%% STEP 3
% bootstrapping without imposing prior knowledge

USE_SYMMETRY = 0;   % flag for imposing symmetry prio knowledge
M1=[];              % not implemented
iter = 5;           % number of iterations
% [superParticleWithoutPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, USE_SYMMETRY, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);