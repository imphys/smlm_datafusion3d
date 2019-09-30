% consistencyCheck      apply the absolute registration parameters to 
%   particles to make the data-driven template
%
% SYNOPSIS:
%   [initAlignedParticles, sup] = makeTemplate(M_new, ptCloudTformed, subParticles, N)
%
% INPUT
%   M_new
%       the second absolute transformations
%   ptCloudTformed
%       point cloud of particles
%   subParticles
%       the inital particles
%   N 
%       the number of particles
%
% OUTPUT
%   initAlignedParticles
%       the initial aligned particles
%   sup
%       data-driven template
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2019

function [initAlignedParticles, sup] = makeTemplate(M_new, ptCloudTformed, subParticles, N)

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

end