% ang2q  convert rotation angles to quaternion.
%
% SYNOPSIS:
%   function q = ang2q(r1, r2, r3)
%
% INPUT
%   r1, r2, r3  
%       Euler angles
%
% OUTPUT
%   q   
%       quternion representation
%    
%
%   NOTE:
%       the function is adapted from angle2quant() from MATLAB
%
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Author: Hamidreza Heydarian, 2019 

function q = ang2q(r1, r2, r3)
%  ang2q Convert rotation angles to quaternion.


    angles = [r1(:) r2(:) r3(:)];

    cang = cos( angles/2 );
    sang = sin( angles/2 );


    q = [ cang(:,1).*cang(:,2).*cang(:,3) + sang(:,1).*sang(:,2).*sang(:,3), ...
        cang(:,1).*cang(:,2).*sang(:,3) - sang(:,1).*sang(:,2).*cang(:,3), ...
        cang(:,1).*sang(:,2).*cang(:,3) + sang(:,1).*cang(:,2).*sang(:,3), ...
        sang(:,1).*cang(:,2).*cang(:,3) - cang(:,1).*sang(:,2).*sang(:,3)];

end
