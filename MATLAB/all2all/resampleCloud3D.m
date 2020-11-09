% resampleCloud2D   subsamples the particle based on density of
% localizations
%
% SYNOPSIS:
%   [NewParticle] = resampleCloud2D(Particle)
%
% INPUT
%   Particle
%       The particle to be downsampled.
%
% NewParticle
%       The downsampled particle.
%
% NOTES
%       The weights for downsampling are computed using the intensity of 
%       the image resulting from binning and smoothing the localizations.
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


function [ NewParticle ] = resampleCloud3D(Particle, weights)

    S = size(Particle.points,1);                % particles size
    cutoff = 5000;                              % the max number of 
                                                % localizations to be kept

    % perform the weighted resampling
    ids = datasample(1:S,min(cutoff, S),'Replace',false,'Weights',weights);
%     ids = datasample(1:S,cutoff,'Replace',false);

    % new particle
    NewParticle.points = Particle.points(ids,:);
    NewParticle.sigma = Particle.sigma(ids,:);

end