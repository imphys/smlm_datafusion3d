% M2RM   computes the relative transformation matrix RM from the absolute M
%
% SYNOPSIS:
%   RM = M2RM(M)
%
% INPUT
%   M
%       Absolute motion matrix (rotation+translation)
%
% OUTPUT
%   RM
%       Relative motion matrix (rotation+translation)
%
% NOTES
%   M_ij = M_j^-1 x M_i
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


function RM = M2RM(M)
    
    RM = zeros(4,4,5);
    nParticles = size(M,3);
    kk = 1;
    for i=1:nParticles-1
        for j=i+1:nParticles

            relAngleR(kk) = atan2(-M(2,1,i),M(1,1,i)) + atan2(M(2,1,j),M(1,1,j));
            curestAngle = wrapToPi(relAngleR(kk));
            w_est = curestAngle * [0;0;1];
            RM(1:3,1:3,kk) = expm([0,-w_est(3),w_est(2); w_est(3),0,-w_est(1); -w_est(2),w_est(1),0]); 
            translation = -M(1:2,4,i) + M(1:2,4,j);
            RM(:,4,kk) = [translation; 0; 1]; 
            kk = kk+1;

        end
    end
            
end