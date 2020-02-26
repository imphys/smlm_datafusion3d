% pairFitting3D  register a pair of particles
%
% SYNOPSIS:
%   param = pairFitting3D(ptc1, ptc2, sig1, sig2, scale, nIteration, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST)
%
% INPUT
%   ptc1  
%       point cloud of particle 1
%   ptc2  
%       point cloud of particle 2
%   sig1  
%       uncertainties for points in ptc1
%   sig2  
%       uncertainties for points in ptc2
%   nIteration    
%       maximal number of iterations in fit 
%   USE_GPU_GAUSSTRANSFORM 
%       1/0 for using GPU/CPU
%   USE_GPU_EXPDIST 
%       1/0 for using GPU/CPU
%
% OUTPUT
%   param       transformations parameter giving the highest cost
%    
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Author: Hamidreza Heydarian, 2019 

function param = pairFitting3D(ptc1, ptc2, sig1, sig2, scale, nIteration, USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST)

% multiple start
ang1 = [0 pi/2 pi 3*pi/2];
ang2 = [0];
ang3 = [0];

[a, b, c] = ndgrid(ang1,ang2,ang3);

for init_iter=1:numel(a)

    qtmp = ang2q(a(init_iter), b(init_iter), c(init_iter));
    
    % initialize gmmreg
    f_config = initialize_config(double(ptc1), double(ptc2), 'rigid3d', nIteration);
    f_config.init_param = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];
    f_config.scale = scale;     
    
    % perform registration
    tmpParam{1,init_iter} = gmmreg_L23D(f_config,USE_GPU_GAUSSTRANSFORM); 
    
    % calculate cost again and store
    M = double(ptc1);
    S = double(ptc2);

    M_points_transformed = transform_pointset(M, 'rigid3d', tmpParam{1,init_iter});
    RM = quaternion2rotation(tmpParam{1,init_iter}(1:4));
    if USE_GPU_EXPDIST
        cost(init_iter) = mex_expdist(S, M_points_transformed, correct_uncer(sig2), sig1, RM);
    else
        cost(init_iter) = mex_expdist_cpu(S, M_points_transformed, sig2, sig1, RM);
    end

end

% find maximal costs and store results
[maxCost, idx] = max(cost);
param = tmpParam{1,idx};

end