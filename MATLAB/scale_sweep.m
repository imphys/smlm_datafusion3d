function [optimal_scale,scales_vec,cost_log,idxP] = scale_sweep(particles,numsample,PLOT_COST_LANDSCAPE)
%SCALE_SWEEP aligns randomly chosen particles over a range of GMM scales to
%find the optimal scale. The GMM alignemnt is initialised with a fixed
%number of initial angles.
% 
% input:
% 
% particles : cell array of particle structs
% numsample : number of particles to align over the scale range
% PLOT_COST_LANDSCAPE : flag indicating whether or not to plot the cost vs.
%                                               scale landscape after all alignment has been done
% 
% output:
% 
% scales_vec : vector of scale range used for sweep
% cost_log : cost matrix for all numsmaple particle pairs and all scales_vec
%               scales
% idxP : index list of the particles selected for alignment. particle 1 is
%               aligned against particle 1+numsample etc.
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Maarten Joosten, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0


initAng = 2;     % dummy parameter used to set the number of initial angles in pairFitting
% scales_vec = linspace(0.001,0.5,30);          % fine scales vector
scales_vec = linspace(0.001,1.5,30);                 % coarse scale vector

% use GPU code
USE_GPU_GAUSSTRANSFORM = true;
USE_GPU_EXPDIST = true;

% pick particle pairs
idxP = datasample(1:length(particles),2*numsample,'Replace',false);

tic
for ii=1:numsample
    disp(['aligning pair ',num2str(ii),' out of ',num2str(numsample)])
    par1 = particles{idxP(ii)};
    par2 = particles{idxP(ii+numsample)};
    
    cost = zeros(length(scales_vec),1);                 % initialise array to store cost function value for each scale

    iter=1;                 
    for scale = scales_vec
        [~,cost(iter)] = pairFitting3D(par1.coords(:,1:3), par2.coords(:,1:3), ...
                        par1.coords(:,[5,10]).^2, par2.coords(:,[5,10]).^2, scale, initAng, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST);
        iter = iter+1;
    end

    cost_log(ii,:) = cost;
end
toc

optimal_scale = scales_vec(find(mean(cost_log)==max(mean(cost_log))));


if PLOT_COST_LANDSCAPE
    figure
    plot(scales_vec,mean(cost_log),'linewidth',4)
    hold on
    errorbar(scales_vec,mean(cost_log),std(cost_log))
    grid on
    xlabel('scale parameter value')
    ylabel('cost function value')
    % line([0.25 0.25],ylim,'linestyle','--','color','red')
    set(gca,'FontSize',20)
end
end

