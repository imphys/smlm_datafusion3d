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
% (C) Copyright 2019               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2019

function invT = invTransform(estA)

    invT = inv(estA);
    invT(:,end) = [0;0;0;1];
    
end