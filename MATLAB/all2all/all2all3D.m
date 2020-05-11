% all2all3D   compute all2all registration matrix
%
% SYNOPSIS:
%   [RR, I] = all2all3D(subParticles, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
%
% INPUT
%   subParticles
%       N given particles
%   USE_GPU_GAUSSTRANSFORM 
%       1/0 for using GPU/CPU
%   USE_GPU_EXPDIST 
%       1/0 for using GPU/CPU
%
% OUTPUT
%   RR
%       relative transformation rotation and translation of size
%       4x4xN(N-1)/2
%   I
%       connectivity matrix of size 2xN*(N-1)/2
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2019

function [RR, I, cost] = all2all3D(subParticles, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

    N = numel(subParticles);

    % filling out the all2all registration matrix (result)
    result = cell(N-1,N);
    cost = zeros(N);
    
    for i=1:N-1
        parfor j=i+1:N

            [param,cost(i,j)] = pairFitting3D(subParticles{1,i}.points, subParticles{1,j}.points, ...
                               subParticles{1,i}.sigma, subParticles{1,j}.sigma, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);

            result{i,j}.parameter = param;
            result{i,j}.id = [i; j];  
            result{i,j}.cost = cost(i,j);

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
            RR(1:3,1:3,k) = q2R(q)';
            RR(1:3,4,k) = [result{i,j}.parameter(5); result{i,j}.parameter(6); result{i,j}.parameter(7)];
            RR(4,4,k) = 1;
            RR(4,1:3) = 0;

            % I holds the connectivity of pairs of size 2xN(N-1)/2
            I(:,k)=result{i,j}.id;
            k=k+1;        
        end
    end

end