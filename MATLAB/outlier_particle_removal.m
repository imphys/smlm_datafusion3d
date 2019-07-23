%outlier_particle_removal   remove outlier particles from a set of aligned
%particles
%
% SYNOPSIS:
%  outlierParticleID = outlier_particle_removal(finalParticles, scale)
% INPUT:
%   finalParticles: the set of all aligned particles after bootstrapping.
%   scale: scale parameter which is the same as GMM-based registration in
%   all2all3D funcion.
%
% OUTPUT:
%   outlierParticleID: the indices of the outlier particles in
%   superparticle
%
% NOTE:
%   Currently, we use the GaussTransform as the cost function. The other
%   option is to use Bhatt. cost funciton.


function outlierParticleID = outlier_particle_removal(finalParticles, scale)

    N = numel(finalParticles);  % number of particles
    fval = zeros(N,N);          % the all to all matrix
%     scale  =0.1;

    % all to all scores
    k=1;
    for i=1:N-1
        for j=i+1:N
            fval(i,j) = GaussTransform(finalParticles{1,i}.points, finalParticles{1,j}.points, scale);
            k=k+1;
        end
    end

    all2all_fval = fval + fval';           % make the all to all symmetric
    all2all_fval_avg = mean(all2all_fval); % one score per particle

    % outlier particle indices
    outlierParticleID = find(isoutlier(all2all_fval_avg));
    
end