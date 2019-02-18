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
% (C) Copyright 2017               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2017

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