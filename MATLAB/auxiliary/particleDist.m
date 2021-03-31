% particleDist  compute the distance between two particles using their binding 
%   sites from the design model size (only for NPC with 32 sites without flipping).
%
% SYNOPSIS:
%   [D] = particleDist(par1, par2)
%
% INPUT
%   par1: the sites of the first particle  
%   par2: the sites of the second particle
%
% OUTPUT
%   D: the distance in particle unit  
%      
%   NOTE:% compute the distance between two particles of size 32x3
%   For NPC particles that have very high tilt and due to the symmetry
%   of the top and bottom ring, a flip match can happen.
%   The problem is that the top/bottom rings are not consistent and we
%   need to modify the NPC model to solve this problem.
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

function D = particleDist(par1, par2)

    Dist = zeros(1,8);
    chunk1 = par2(1:8,:);      % upper ring 1 set
    chunk2 = par2(9:16,:);     % upper ring, shifted by 10 deg to make dubble blob per set
    chunk3 = par2(17:24,:);    % lower ring
    chunk4 = par2(25:32,:);    % lower ring, shifted by 10 deg to make dubble blob per set

    for i=1:8
        tmpPar2 = [circshift(chunk1, i-1);
                            circshift(chunk2, i-1);
                            circshift(chunk3, i-1);
                            circshift(chunk4, i-1)];
        Dist(i) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));
    end

    % % suggestion from bernd for uppper lower flipping
    % for i=9:16
    %     tmpPar2 = [circshift(chunk3, i-1);
    %                         circshift(chunk4, i-1);
    %                         circshift(chunk1, i-1);
    %                         circshift(chunk2, i-1)];
    %     Dist(i) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));
    % end

    D = min(Dist);

end