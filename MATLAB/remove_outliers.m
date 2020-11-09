%remove_outliers   the outlier removal routine based on geodesic distance
%between the lie-algebra averaging relative transformation and the initial
%computed relative transformations (NOT USED ANYMORE)
%
% SYNOPSIS:
%  [RR, I] = remove_outliers(RR, I, Mest, outlier_threshold)
%
% INPUT:
%   RR: initial relative transformaitons
%   I: indicator matrix (i,j)->particle_i to particle_j
%   Mest: absolute tranformation after lie-algebra averaging
%   outlier_threshold:  threshold for geodesic distance 
%
% OUTPUT:
%   finalParticles: final particles after alignment
%   transform:      absolute transformation for each final particle
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

function [RR, I] = remove_outliers(RR, I, Mest, outlier_threshold)

if size(RR,3) <= 1; return; end

n_particles = size(Mest, 3);

kk = 1;
relR = zeros(3,3,1);
for i=1:n_particles-1
    for j=i+1:n_particles

        relR(:,:,kk) = Mest(1:3,1:3,j)'*Mest(1:3,1:3,i);
        kk = kk+1;

    end
end

d = zeros(size(RR,3),1);

for i=1:size(RR,3)
   d(i) =  distSE3(RR(:,:,i),relR(:,:,i));
end

error_idx = abs(d) > outlier_threshold;

RR(:,:,error_idx) = [];
I(:,error_idx) = [];

end