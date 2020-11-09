%VISUALCLOUD2D 3D scatter plot of the points with an intensity proportional
%to its local density
% 
% SYNOPSIS:
%   visualizeCloud2D(pointcloud, bins, diameter, angle)
% 
% INPUT
%   pointcloud
%       [x y z; ...] (for example Particle{10}.points)
%   scale
%       the scale parameters of Gauss transform
% 
% OUTPUT
%   dip
%       dip image structure
%   Z
%       image matrix
%
% DEFAULTS:
%   none
% 
% NOTES:
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


function [density] = visualizeCloud3D(data, scale, USE_GPU)

    density = zeros(size(data,1),1);   
    
%     idxTop = find(data(:,3) > 0);
%     for i=1:size(idxTop,1)
% 
%         [density(idxTop(i)),~] = GaussTransform(data(idxTop,:),data(idxTop(i),:), scale);
% 
%     end        
%     
%     idxBottom = find(data(:,3) <= 0);
%     for i=1:size(idxBottom,1)
% 
%         [density(idxBottom(i)),~] = GaussTransform(data(idxBottom,:),data(idxBottom(i),:), scale);
% 
%     end        
    
    % compute the intensity of each point using the Gauss transform
    for i=1:size(data,1)

        [density(i),~] = GaussTransform(data,data(i,:), scale, USE_GPU);

    end    
    
    % uncomment for new figure
%     figure('pos',[100 100 500 500]);
figure;
    scatter3(data(:,1),data(:,2), data(:,3),1,density,'.');
    
    colormap(hot);
    set(gca,'Color','k');
    set(gca, 'FontSize', 16,'FontWeight','bold')

%     set(gca,'XLim',[-1 1],'YLim',[-1 1],'ZLim',[-1 1])
    axis equal, axis square
%     cdensity = buildcmap(density);
%     figure,showset(data,cdensity);    

end