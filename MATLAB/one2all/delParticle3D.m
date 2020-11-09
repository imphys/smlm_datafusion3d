%one2all   remove localization data of index idx from fused particles fusedParticles
% of particles
%
%   SYNOPSIS:
%       S = delParticle(Particles, fusedParticles, idx)
%
%   Input: 
%       Particles: Cell array of original particles of size 1xN
%       fusedParticles: Cell array of fused particles
%       idx: index of the particle to be removed
%
%   Output:
%       S: Cell array of fusedParticles without Particles{1,idx}
%
%   NOTE:
%       This function removes the Particles{1,idx} from the stacked
%       fusedParticles.

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


function [curweight, S] = delParticle3D(Particles, fusedParticles, idx, weight)
% % function [curweight, S] = delParticle(Particles, fusedParticles, idx)
    
    curweight = weight;
    S = fusedParticles;
    particlesSize = 0;
    
    for i=1:idx-1
            
        particlesSize = particlesSize + size(Particles{1,i}.points, 1);
        
    end
    
   curParticleSize = size(Particles{1,idx}.points, 1);
   
   S.points(particlesSize+1:(particlesSize + curParticleSize),:) = [];
   S.sigma(particlesSize+1:(particlesSize + curParticleSize),:) = [];
   curweight(particlesSize+1:(particlesSize + curParticleSize),:) = [];
   
end