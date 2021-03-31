%transform_coordinates   apply rotation and translation to list of
%coordinates
%
% SYNOPSIS:
%  transformed_coordinates = transform_coordinates(coordinates, rotation, shift)
% INPUT:
%   coordinates: list of coordinates
%   rotation: rotation matrix
%   shift: translation vecotor
%
% OUTPUT:
%   transformed_coordinates: transformed coordinates
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
function transformed_coordinates = transform_coordinates(coordinates, rotation, shift)
    
shift = repmat(shift, size(coordinates,1),1);
transformed_coordinates =  coordinates * rotation + shift;

end