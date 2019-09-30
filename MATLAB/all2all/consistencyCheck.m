% consistencyCheck   consistency check of the recomputed transformations
% with the initial estimates
%
% SYNOPSIS:
%   [RM_new, I_new] = consistencyCheck(Mest, RR, I, N)
%
% INPUT
%   Mest
%       the first absolute transformations
%   RR
%       relative transformation rotation and translation of size
%       4x4xN(N-1)/2
%   I
%       connectivity matrix of size 2xN*(N-1)/2
%   N 
%       the number of particles
%
% OUTPUT
%   RM_new
%       relative transformation rotation and translation of size
%       4x4xK(K-1)/2 after consistency check, K<=N
%   I_new
%       connectivity matrix of size 2xK*(K-1)/2 after consistency check,
%       K<=N
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2019

function [RM_new, I_new] = consistencyCheck(Mest, RR, I, N)

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

end