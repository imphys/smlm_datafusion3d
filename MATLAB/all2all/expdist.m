% expdist           Apply rigid transform to the point set and invoke 
%                   executive to evaluate Bhattacharya cost function
%
% SYNOPSIS:
%   D = expdist(S, M, angle, t1, t2)
%
% PARAMETERS:
%   S
%      The first particle (struct with points and sigma as fields)
%   M
%      The second particle (struct with points and sigma as fields)
%   angle
%      in-plane rotation angle to be applied to M
%   [t1, t2]
%      2D translation paramteres 
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


function D = expdist(S, M, angle, t1, t2)

    R = [cos(angle) -sin(angle); sin(angle) cos(angle)];    % rotation matrix
    t = [t1 t2]; % translation vector
    
    % transform the model
    Mt.points = M.points * R' + repmat(t, size(M.points,1), 1);
    Mt.sigma = M.sigma;
    
    % compute the Bhatacharya cost function
    % run GPU version if it exists otherwise fall back to CPU version
    if exist('mex_expdist','file')
        D = mex_expdist(Mt.points, S.points, Mt.sigma, S.sigma);
    elseif exist('mex_expdist_cpu','file')
        D = mex_expdist_cpu(Mt.points, S.points, Mt.sigma, S.sigma);
    else
        message = ['No compiled modules found for ExpDist.\n' ...
            'Please run make in the top-level directory first.']; 
        message_id = 'MATLAB:MEXNotFound';
        error (message_id, message);


end


