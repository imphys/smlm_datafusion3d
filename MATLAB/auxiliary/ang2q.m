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
