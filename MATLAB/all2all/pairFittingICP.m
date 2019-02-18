function [parameter, registered_model, history, config, max_value] = pairFittingICP(M, S) 
    
    scale = [0.001];                 % the set of scales in a multiscale 
                                    % approach these are roughly equal to
                                    % one and 5 times the average 
                                    % uncertainties (1nm) and (to be 
                                    % determnined automatically.)
                                    
    angle = [-pi -pi/2 0 pi/2 pi 3*pi/2 2*pi];     % inital angles

    % an automatic scale selection 
    % [n,d] = size(M.points);
    % scale = power(det(M.points'*M.points/n), 1/(2^d))/2;    
    
	% generate all permutation of initial grid and scale
	[init_scale, init_angle] = ndgrid(scale, angle);
	N_init = numel(init_scale);

    % initalize functions outputs
    param = cell(1, N_init);                    % rotation & translation
    transformed_model = cell(1, N_init);        % fused particle
    bhattacharyya_distance = zeros(1, N_init);  % bhattacharyya distance
    history = cell(1, N_init);                  % optimization variable
    config = cell(1, N_init);                   % struct for GMM algorithm
    
    % resample particles to save time
    M_resampled = resampleCloud2D(M);
    S_resampled = resampleCloud2D(S);   
    
	% loop over scales and inital angles
    for iter = 1:N_init
        
        % initialize the GMM registration method
        f_config = initialize_config(M_resampled.points, S_resampled.points, 'rigid2d');
        f_config.init_param = [0, 0, init_angle(iter)];
        f_config.scale = init_scale(iter);

        % perform registration
%         [param{iter}, transformed_model{1, iter}.points, history, config, fval(iter)] = gmmreg_L2(f_config);
        [param{iter}, ~, ~, ~, ~] = regICP(M_resampled.points, S_resampled.points); 
%         transformed_model{1, iter}.sigma = [M_resampled.sigma; S_resampled.sigma];

        % compute the Bhattacharyya distance
        bhattacharyya_distance(iter) = expdist(S_resampled, M_resampled, param{iter}(1,3), param{iter}(1,1), param{iter}(1,2));
        
    end
			
    % maximize over scales and inital angles
    [max_value, IDX] = max(bhattacharyya_distance);
    parameter = param{1,IDX};
    M_transformed.points = transform_by_rigid2d(M.points, parameter);
    M_transformed.sigma = M.sigma;
    registered_model.sigma = [M_transformed.sigma; S.sigma]; 
    registered_model.points = [M_transformed.points; S.points]; 
	        
end
