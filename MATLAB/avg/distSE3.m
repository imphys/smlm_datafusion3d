% distSE3  compute the geodesic distance between two transformation matrix
% (SE3)
%
% SYNOPSIS:
%   d = distSE3(X,Y)
%
% INPUT
%   X  
%       transformation matrix 1 (4x4)
%   Y  
%       transformation matrix 2 (4x4)
%
% OUTPUT
%   d       
%       the geodesic distance
%    
% NOTE
%       reference: Park, F. C. Distance Metrics on the Rigid-Body Motions 
%       with Applications to Mechanism Design. Journal of Mechanical Design 117, 48 (1995).
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Author: Hamidreza Heydarian, 2019 

function d = distSE3(X,Y)

    % rotation matrix similarity
    R1 = X(1:3,1:3);
    R2 = Y(1:3,1:3);

    d = sqrt(trace(logm(R1'*R2)'*logm(R1'*R2))/2);

end
