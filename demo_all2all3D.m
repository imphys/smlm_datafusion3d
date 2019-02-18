%% 

% add gmmreg registration path
addpath(genpath('MATLAB'));

% load data
filename = '3D_NUP107_ph1000_dol40_tr20nm_3D_storm_kb5_ang3D_7.mat';
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
        k=k+1;        
    end
end

%% all2all averaging

disp('rotation averaging started!');
% average relative rotations+translation to get the absolute ones (Mest)
Mest = MeanSE3Graph(RR, I);

%% outlier removal

% relative all2all rotation and translation after averaging
kk = 1;
relTr = zeros(2,5);
relR = zeros(3,3,1);
for i=1:NN-1
    for j=i+1:NN

        relR(:,:,kk) = Mest(1:3,1:3,j)'*Mest(1:3,1:3,i);
        kk = kk+1;

    end
end

for i=1:size(RR,3)
   d(i) =  distSE3(RR(:,:,i),relR(:,:,i));
end

error_idx = find(abs(d)>1);                         % threshold, should be automated

RM_new = RR;
I_new = I;
RM_new(:,:,error_idx) = [];                         % exclude outliers                        
I_new(:,error_idx) = [];                            % exclude outliers
%% second averaging

[M_new] = MeanSE3Graph(RM_new,I_new);
% Mest = M_new;
disp('2nd rotation averaging done!');
%% apply the absolute registration parameters to particles

sup =[];
for i=1:N       
    
    estA = eye(4);
    estA(1:3,1:3) = M_new(1:3,1:3,i); 
    estA(4,:) = M_new(:,4,i)';
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

%%
M1=[];
iter = 10;
[superParticleWithoutPK, ~] = one2all3D(initAlignedParticles, iter, M1, '.', sup, 0);