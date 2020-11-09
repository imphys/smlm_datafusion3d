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


function [initAlignedParticles, sup] = makeTemplate(M_new, subParticles, N)

    initAlignedParticles = cell(1,N);   % first aligned particles
    sup =[];                            % data-driven template
    for i=1:N       

%         estA = eye(4);
%         estA(1:3,1:3) = M_new(1:3,1:3,i); 
%         estA(4,:) = M_new(:,4,i)';
%         estTform = invTransform(estA);
%         r = estTform(1:3, 1:3);
%         t = estTform(4, 1:3);
        r = inv(M_new(1:3,1:3,i));
        t = M_new(:,4,i)';
        
        % transform each particle
        subParticlesTformed = subParticles{1,i}.points * r;
        subParticlesTformed(:,1) = subParticlesTformed(:,1) + t(1);
        subParticlesTformed(:,2) = subParticlesTformed(:,2) + t(2);
        subParticlesTformed(:,3) = subParticlesTformed(:,3) + t(3);        

        % initial aligned particles for bootstrapping
        initAlignedParticles{1,i}.points = subParticlesTformed;
        initAlignedParticles{1,i}.sigma = subParticles{1,i}.sigma;    

        % stack all registered particles
        sup = [sup; subParticlesTformed];

    end

end