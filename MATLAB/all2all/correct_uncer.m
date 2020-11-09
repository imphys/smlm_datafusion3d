% correct_uncer
% Makes sure that the uncertainties have the right format to be used by
% mex_expdist. Note that this function must only be used to reformat the 
% sigmas of the first particle (which is not transformed) and when using 
% the GPU function (mex_expdist) and 
%
%   SYNOPSIS:
%       [sigmas_corrected] =correct_uncer(sigmas_in)
%
%   Input: 
%      sigmas_in
%           a Nx2 array containing all sigma_xy and sigma_z per
%           localization ordered horizontally: 
%           sigmas_in = [Sig1_xy Sig1_z ; 
%                                 Sig2_xy Sig2_z ; 
%                                                     ... ]
%
%   Output:
%       sigmas_corrected
%           corrected format for the sigmas, necessary to use mex_expdist.
%           Now the uncertainties per particle are ordered vertically,
%           starting in the upperleft corner, filling the matrix
%           column-wise
%           sigmas_corrected =[Sig1_xy Sig50_xy ; 
%                                            Sig1_z   Sig50_z ; 
%                                            Sig2_xy Sig51_xy;
%                                                                       ... ]
%
%
% (C) Copyright 2018-2020      
% Faculty of Applied Sciences
% Delft University of Technology
%
% Teun Huijben, November 2020.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%    http://www.apache.org/licenses/LICENSE-2.0

function [sigmas_corrected] = correct_uncer(sigmas_in)

    sigmas_corrected = reshape(sigmas_in',size(sigmas_in,1),size(sigmas_in,2)); 
    
end