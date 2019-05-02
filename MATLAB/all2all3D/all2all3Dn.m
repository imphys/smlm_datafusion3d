function param = all2all3Dn(ptc1, ptc2, sig1, sig2, nIteration)
% ptc1  point cloud of particle 1
% ptc2  point cloud of particle 2
% sig1  uncertainties for points in ptc1
% sig2  uncertainties for points in ptc2
% nIteration    maximal number of iterations in fit
%
% Output
%   param       transformations parameter giving the highest cost

% multiple start
ang1 = [0 pi/2 pi 3*pi/2];
ang2 = [0];% pi/4 -pi/4];
ang3 = [0];% pi/4 -pi/4];

[a, b, c] = ndgrid(ang1,ang2,ang3);

for init_iter=1:numel(a)

%     qtmp = angle2quat(ang(init_iter), 0, 0);
    qtmp = angle2quat(a(init_iter), b(init_iter), c(init_iter));
    
    % initialize gmmreg
    f_config = initialize_config(double(ptc1), double(ptc2), 'rigid3d', nIteration);
    f_config.init_param = [qtmp(2) qtmp(3) qtmp(4) qtmp(1) 0 0 0];
    f_config.scale = 0.1;     % TODO  (JKF) Should sig1,sig2 not also be used in gmmreg_L23D? Currently only used for cost calculation?
    % perform registration
    tmpParam{1,init_iter} = gmmreg_L23D(f_config); 
    
    % calculate cost again and store
    M = double(ptc1);
    S = double(ptc2);
    q = [tmpParam{1,init_iter}(4) tmpParam{1,init_iter}(1) tmpParam{1,init_iter}(2) tmpParam{1,init_iter}(3)];
    tmpRR = q2R(q);
    tmpTT = repmat([tmpParam{1,init_iter}(5) tmpParam{1,init_iter}(6) tmpParam{1,init_iter}(7)], size(M,1),1);
    M = (M - tmpTT) * tmpRR' * tmpRR';
    if exist('mex_expdist','file') && gpuDeviceCount > 0
        cost(init_iter) = mex_expdist(S, M, sig2, sig1, tmpRR');
    else
        cost(init_iter) = mex_expdist_cpu(S, M, sig2, sig1, tmpRR');
    end

end

% find maximal costs and store results
[maxCost, idx] = max(cost);
param = tmpParam{1,idx};

end