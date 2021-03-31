% invTransform      invert geometric transformation 
%
% SYNOPSIS:
%   invT = invTransform(estA)
%
% INPUT
%   estA
%       the 4x4 transformations in homogeneous coordinate
%
% OUTPUT
%   invT
%       the initial aligned particles
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


function invT = invTransform(estA)

    invT = inv(estA);
    invT(:,end) = [0;0;0;1];
    
end