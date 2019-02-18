%% 

% add gmmreg registration path
addpath(genpath('MATLAB'));

% load data
filename = '3D_NUP107_ph1000_dol100_tr20nm_3D_paint_ang3D_5.mat';
load(['data/' filename]);

NN = 256;                          % the number of particles to be included
% sup=[];
for i=1:NN
    Particles{1,i}.points = particles{1,i}.coords(:,1:3);
    idxZ = find(Particles{1,i}.points(:,3) > 1 | Particles{1,i}.points(:,3) < -1);
    Particles{1,i}.points(idxZ,:) = [];
    Particles{1,i}.sigma = [particles{1,i}.coords(:,5).^2 particles{1,i}.coords(:,10).^2];
    Particles{1,i}.sigma(idxZ,:) = [];
%     sup=[sup;Particles{1,i}.points];
end

%% all-to-all registration

for i=1:NN
        ptCloudTformed{i} = pointCloud(Particles{1,i}.points);
end

N = NN;

% filling out the all2all registration matrix (result)
result = cell(NN-1,NN);
for i=1:N-1
    parfor j=i+1:N
        
        param = all2all3Dn(ptCloudTformed{i}.Location,ptCloudTformed{j}.Location, ...
                           Particles{1,i}.sigma, Particles{1,j}.sigma, 1);

        result{i,j}.parameter = param;
        result{i,j}.id = [i; j];       
        
    end    
    disp(['row ' num2str(i) ' is done.'])
    
end
%%
% convert quaternion to matrix representation (SE3)
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
        
        %%SE-sync params
        measurements.edges(k,:) = I(:,k)';
        measurements.R{k} = RR(1:3,1:3,k);
        measurements.t{k} = RR(1:3,4,k);
        measurements.kappa{k} = 1;
        measurements.tau{k} = 1;             
        
        k=k+1;        
    end
end
%% SE-Sync
num_poses = max(max(measurements.edges));
d = length(measurements.t{1});
    
% Set Manopt options (if desired)
Manopt_opts.tolgradnorm = 1e-2;  % Stopping tolerance for norm of Riemannian gradient
Manopt_opts.rel_func_tol = 1e-5;  % Additional stopping criterion for Manopt: stop if the relative function decrease between two successive accepted iterates is less than this value
Manopt_opts.miniter = 1;  % Minimum number of outer iterations (i.e. accepted update steps) to perform
Manopt_opts.maxiter = 300;  % Maximum number of outer iterations (i.e. accepted update steps) to perform
Manopt_opts.maxinner = 500;  % Maximum number of iterations for the conjugate-gradient method used to compute approximate Newton steps

% Set SE-Sync options (if desired)
SE_Sync_opts.r0 = 5;  % Initial maximum-rank parameter at which to start the Riemannian Staircase
SE_Sync_opts.rmax = 10;  % Maximum maximum-rank parameter at which to terminate the Riemannian Staircase
SE_Sync_opts.eig_comp_rel_tol = 1e-4;  % Relative tolerance for the minimum-eigenvalue computation used to test for second-order optimality with MATLAB's eigs() function
SE_Sync_opts.min_eig_lower_bound = -1e-3;  % Minimum eigenvalue threshold for accepting a maxtrix as numerically positive-semidefinite
SE_Sync_opts.Cholesky = false;  % Select whether to use Cholesky or QR decomposition to compute orthogonal projections

use_chordal_initialization = true;  % Select whether to use the chordal initialization, or a random starting point

% Run SE-Sync

% Pass explict settings for SE-Sync and/or Manopt, and use chordal
% initialization
fprintf('Computing chordal initialization...\n');
Rd = chordal_initialization(measurements);
Y0 = vertcat(Rd, zeros(SE_Sync_opts.r0 - d, num_poses*d));
[SDPval, Yopt, xhat, Fxhat, SE_Sync_info, problem_data] = SE_Sync(measurements, Manopt_opts, SE_Sync_opts, Y0);
%%
% transform the computed [R,t] to M format
nParticles = numel(Particles);
Mest = zeros(4,4,2);
for i=1:nParticles
   curR = xhat.R(:,3*(i-1)+1:3*(i-1)+3);
   Mest(1:3,1:3,i) = curR;
   Mest(4,4,i) = 1;
   Mest(1:3,4,i) = xhat.t(:,i);
end

%% all2all averaging

disp('rotation averaging started!');
% average relative rotations+translation to get the absolute ones (Mest)
Mest = MeanSE3Graph(RR, I);

%% apply the absolute registration parameters to particles

sup =[];
for i=1:N       
    
    estA = eye(4);
    estA(1:3,1:3) = Mest(1:3,1:3,i); 
    estA(4,:) = Mest(:,4,i)';
    estTform = affine3d(estA);
    
    % transform each point cloud
    ptCloudestTformed{i} = pctransform2(ptCloudTformed{i}, invert(estTform));
    
    % initial aligned particles for bootstrapping
    initAlignedParticles{1,i}.points = ptCloudestTformed{i}.Location;
    initAlignedParticles{1,i}.sigma = Particles{1,i}.sigma;    
    
    % stack all registered particles
    sup = [sup; ptCloudestTformed{i}.Location];
    
end
%% bootstrapping

M1 = [];    % not implemented
iter = 4;   % number of iterations
[superParticleWithPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, 1);
[superParticleWithoutPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, 0);