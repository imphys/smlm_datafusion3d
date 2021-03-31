% particleDist16  compute the distance between two particles using their binding 
%   sites from the design model size (only for NPC with 16 sites).
%
% SYNOPSIS:
%   [D, flipflag] = particleDist16(par1, par2)
%
% INPUT
%   par1: the sites of the first particle  
%   par2: the sites of the second particle
%
% OUTPUT
%   D: the distance in particle unit  
%   flipflag: does flipping happen?
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

function [D, flipflag] = particleDist16(par1, par2)

flipflag = 0;                        % flip match?
Dist = zeros(1,8);
chunk1 = par2(1:8,:);        % upper ring 1 set
chunk2 = par2(9:16,:);      % lower ring

%     uncomment for visualizing correspondence
%     figure

for i=1:8
    tmpPar2 = [circshift(chunk1, i-1);
                        circshift(chunk2, i-1)];
    Dist(i) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));
    
%     uncomment for visualizing correspondence
%     subplot(2,8,i);
%     scatter3(par1(:,1),par1(:,2),par1(:,3),'.')
%     hold on
%     scatter3(tmpPar2(:,1),tmpPar2(:,2),tmpPar2(:,3),'.')
%     hold on
%     quiver3(par1(:,1),par1(:,2), par1(:,3),tmpPar2(:,1)-par1(:,1),tmpPar2(:,2)-par1(:,2), tmpPar2(:,3)-par1(:,3),0);                    

end

% check for flipping
for i=1:8
    
    tmpPar2 = [circshift(flipud(chunk2), i-1);
                        circshift(flipud(chunk1), i-1)];
    Dist(i+8) = sum(sqrt(sum((par1 - tmpPar2).^2, 2)));

%     uncomment for visualizing correspondence    
%     subplot(2,8,i+8);
%     scatter3(par1(:,1),par1(:,2),par1(:,3),'.')
%     hold on
%     scatter3(tmpPar2(:,1),tmpPar2(:,2),tmpPar2(:,3),'.')
%     hold on
%     quiver3(par1(:,1),par1(:,2), par1(:,3),tmpPar2(:,1)-par1(:,1),tmpPar2(:,2)-par1(:,2), tmpPar2(:,3)-par1(:,3),0);
%     hold on
    
end

[D, ID] = min(2*Dist);

if ID > 8
    flipflag = 1;
end

end