% pairFitting   register a pair of particles 
%
% SYNOPSIS:
%   [parameter, registered_model, max_value] = pairFitting3D_parallel(M, S, weight, scale, nIteration, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST) 
%
% INPUT
%   M
%       The first particle.
%   S
%       The second particle.nano 
%   weight
%       a vector of weigth for resampling superparticle localizatio data
%   scale
%       GMM registration scale parameter
%   nIteration    
%       maximal number of iterations in fit 
%   USE_GPU_GAUSSTRANSFORM 
%       1/0 for using GPU/CPU
%   USE_GPU_EXPDIST 
%       1/0 for using GPU/CPU
%
% OUTPUT
%   parameter
%       Rigid registration parameter [q_angle, t1, t2, t3].
%   registered_model
%       The result of registering M to S.
%   max_value
%       The maximum value of the Bhattacharya cost function.
%    
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


function [parameter, registered_model, max_value] = pairFitting3D_parallel(M, S, weight, scale, nIteration, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST) 
    
    % multiple start
    ang1 = [0 pi/2 pi 3*pi/2];
    ang2 = [0];
    ang3 = [0];
    
    [a, b, c] = ndgrid(ang1,ang2,ang3);
    N_init = numel(a);


    tmp_model = cell(1, N_init);        % fused particle

    % resample super particle 
    S_resampled = resampleCloud3D(S, weight);
    
    % pairwise registration
    parfor i=1:N_init
        
        qtmp = ang2q(a(i), b(i), c(i));
        
        q = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];         
    
        f_config = initialize_config(M.points, S_resampled.points, 'rigid3d', nIteration);
        f_config.init_param = q;
        f_config.scale = scale;
        
        % perform registration        
        [param{i}, tmp_model{1,i}, ~, ~, ~] = gmmreg_L23D(f_config,USE_GPU_GAUSSTRANSFORM);
        
    end
    
    parfor i=1:N_init

        M_points_transformed = transform_pointset(M.points, 'rigid3d', param{i});        
        RM = quaternion2rotation(param{i}(1:4));
        if USE_GPU_EXPDIST
            cost(i) = mex_expdist(S_resampled.points, M_points_transformed,...
                                  correct_uncer(S_resampled.sigma), correct_uncer(M.sigma), RM);
        else
            cost(i) = mex_expdist_cpu(S_resampled.points, M_points_transformed,...
                                      correct_uncer(S_resampled.sigma), correct_uncer(M.sigma), RM);
        end
    end

    [max_value, IDX] = max(cost);
    parameter = param{1,IDX};    
	registered_model = tmp_model{1,IDX};
    
end
