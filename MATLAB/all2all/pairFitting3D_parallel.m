% pairFitting   register a pair of particles 
%
% SYNOPSIS:
%   [parameter, registered_model, history, config, max_value] = pairFitting(M, S)
%
% INPUT
%   M
%       The first particle.
%   S
%       The second particle.nano 
%
% OUTPUT
%   parameter
%       Rigid registration parameter [angle, t1, t2].
%   registered_model
%       The result of registering M to S.
%   history
%       History of the optimization variables over iterations (not used!).
%   config
%       The structure containing all the input parameters for GMM based 
%       registration, see '/MATLAB/initialize_config.m'.
%   max_value
%       The maximum value of the Bhattacharya cost function.
%
% NOTES
%       Registration algorithms normally work for a certain range of 
%       rotation angle and scales. In order to avoid trapping in local 
%       minima, different initializations is provided. Then, GMM-based 
%       method, registers the two particles using different
%       intializations. Finally, Bhattacharya cost function, chooses the
%       rigid parameter set which gives the highest score.    
%
% (C) Copyright 2017               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2017

function [parameter, registered_model, max_value] = pairFitting3D_parallel(M, S, weight, scale, nIteration, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST) 
    
    % multiple start
%     ang = [0 pi/4 pi/2 3*pi/4 pi 5*pi/4 3*pi/2 7*pi/4];
    ang1 = [0 pi/2 pi 3*pi/2];
    ang2 = [0];% pi/4 -pi/4];
    ang3 = [0];% pi/4 -pi/4];
    
    [a, b, c] = ndgrid(ang1,ang2,ang3);
    
%     N_init = numel(ang);   
    N_init = numel(a);


    tmp_model = cell(1, N_init);        % fused particle

    % resample super particle 
    S_resampled = resampleCloud3D(S, weight);
    
    % pairwise registration
    parfor i=1:N_init
        
%         qtmp = angle2quat(ang(i), 0, 0);
        qtmp = angle2quat(a(i), b(i), c(i));
        
        q = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];         
    
        f_config = initialize_config(M.points, S_resampled.points, 'rigid3d', nIteration);
        f_config.init_param = q;
        f_config.scale = scale;
        [param{i}, tmp_model{1,i}, ~, ~, ~] = gmmreg_L23D(f_config,USE_GPU_GAUSSTRANSFORM);
        
    end
    
    parfor i=1:N_init
        q = [param{i}(4) param{i}(1) param{i}(2) param{i}(3)];
        tmpRR = q2R(q);
        tmpTT = repmat([param{1,i}(5) param{1,i}(6) param{1,i}(7)], size(M,1),1);

        if USE_GPU_EXPDIST
            cost(i) = mex_expdist(S_resampled.points, (M.points - tmpTT) * tmpRR' * tmpRR',...
                                  S_resampled.sigma, M.sigma, tmpRR');
        else
            cost(i) = mex_expdist_cpu(S_resampled.points, (M.points - tmpTT) * tmpRR' * tmpRR',...
                                      S_resampled.sigma, M.sigma, tmpRR');
        end
    end

    [max_value, IDX] = max(cost);
    parameter = param{1,IDX};    
	registered_model = tmp_model{1,IDX};
    
end
