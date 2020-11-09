% q_norm      compute the norm of a quaternion-1
%
% SYNOPSIS:
%   [c,ceq] = q_norm(x)
%
% INPUT
%   x
%       quaternion
%
% OUTPUT
%   c: reserved
%	ceq:	norm-1
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
function [c,ceq] = q_norm(x)
    c = [];
    ceq = sqrt(x(1)^2 + x(2)^2 + x(3)^2 + x(4)^2) - 1;
end