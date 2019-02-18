% pairFitting   register a pair of particles 
%
% SYNOPSIS:
%   [parameter, registered_model, history, config, max_value] = pairFitting(M, S)
%
% INPUT
%   M
%       The first particle.
%   S
%       The second particle.nano 
%
% OUTPUT
%   parameter
%       Rigid registration parameter [angle, t1, t2].
%   registered_model
%       The result of registering M to S.
%   history
%       History of the optimization variables over iterations (not used!).
%   config
%       The structure containing all the input parameters for GMM based 
%       registration, see '/MATLAB/initialize_config.m'.
%   max_value
%       The maximum value of the Bhattacharya cost function.
%
% NOTES
%       Registration algorithms normally work for a certain range of 
%       rotation angle and scales. In order to avoid trapping in local 
%       minima, different initializations is provided. Then, GMM-based 
%       method, registers the two particles using different
%       intializations. Finally, Bhattacharya cost function, chooses the
%       rigid parameter set which gives the highest score.    
%
% (C) Copyright 2017               Quantitative Imaging Group
%     All rights reserved          Faculty of Applied Physics
%                                  Delft University of Technology
%                                  Lorentzweg 1
%                                  2628 CJ Delft
%                                  The Netherlands
%
% Hamidreza Heydarian, 2017

function [parameter, registered_model, history, config, max_value] = pairFitting3D(M, S) 
    
%     ang = [0 pi/2 pi 3*pi/2];
    ang = [0];
    [ang1, ang2, ang3] = ndgrid(ang, ang, ang);
    N_init = numel(ang1);   

%     init_scale = [0.5 0.1 0.05 0.01];
%     init_scale = 0.05;

    tmp_model = cell(1, N_init);        % fused particle=
    history = cell(1, N_init);                  % optimization variable
    config = cell(1, N_init); 
    
    parfor i=1:N_init
        
%         display(num2str([ang1(i) ang2(i) ang3(i)]));
        qtmp = angle2quat(ang1(i), ang2(i), ang3(i));
        q = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];         
    
        f_config = initialize_config(M.points, S.points, 'rigid3d');
%         f_config.init_param = init_q(i,:);
        f_config.init_param = q;
%         f_config.scale = 0.05;
        f_config.scale = 0.005;
        [param{i}, tmp_model{1,i}, history, config, f_val(i)] = gmmreg_L23D(f_config);
        
    end

%     parfor i=1:size(init_scale,2)
%     
%         f_config = initialize_config(M.points, S.points, 'rigid3d');
%         f_config.scale = init_scale(i);
%         [param{i}, tmp_model{1,i}, history, config, f_val(i)] = gmmreg_L2(f_config);
%         
%     end
    
%     [max_value, IDX] = min(f_val./init_scale.^2);
    [max_value, IDX] = min(f_val);
    parameter = param{1,IDX};    
	registered_model = tmp_model{1,IDX};
    
end
