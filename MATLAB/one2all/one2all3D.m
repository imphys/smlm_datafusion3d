%one2all   Register each particle to the stack of all the remaining
%particles and iterate
% of particles
%
%   SYNOPSIS:
%       [ superParticle, parameter ] = one2all(Particles, iter)
%
%   Input: 
%       Particles: Cell array of particles of size 1xN
%       iter: the number of iterations
%       outdir: output directory to store final super-particle
%
%   Output:
%       superParticle: the resulting fused particle
%       MT: Total transformation parameters (rotation+translation). MT is
%       an 4x4xNxiter matrix.
%
%   NOTE:
%       First, the function concatenates all the particles as they are.
%       Then, each particle is extracted from the stack and registered to
%       the rest. This is done until all particles are registered to the
%       rest. Once done, the whole process is iterated iter times.

% (C) Copyright 2017                    QI Group
%     All rights reserved               Faculty of Applied Physics
%                                       Delft University of Technology
%                                       Lorentzweg 1
%                                       2628 CJ Delft
%                                       The Netherlands
%
% Hamidreza Heydarian, Oct 2017.

function [ superParticle, MT] = one2all3D(Particles, iter, oldM, outdir, sup, symmetry_order)

%     disp('Bootstapping is started  !');
    
    [density] = visualizeSMLM3D(sup, 0.1, 0);
    weight = density/max(density);

    initParticle.points = [];
    initParticle.sigma = [];
    N = numel(Particles);
%     scale = [0.1 0.1 0.1 0.05 0.025];
    scale = 0.1*ones(1, iter);%[0.1 0.1 0.1 0.1];
   
    
    for i=1:N
        
        initParticle.points = [initParticle.points;Particles{1,i}.points];
        initParticle.sigma = [initParticle.sigma;Particles{1,i}.sigma];
        
    end
    
    superParticle{1} = initParticle.points;

    % one-to-all registration, excludes each particle from the superparticle
    % and then register it to the rest
    for j=1:iter

        tmpParticle.points = [];
        tmpParticle.sigma = [];        
        tic;
        for i=1:N

%             if (~mod(i,5))
%                 disp(['iter #' num2str(j) ' of ' num2str(iter) ': registering particle #' num2str(i) ' on initial ']);
%             end
            M = Particles{1,i};
            [curWeight, S] = delParticle3D(Particles, initParticle, i, weight);
            [parameter{j,i}, ~, ~] = pairFitting3D_parallel(M, S, curWeight, scale(j), j);

            if nargin > 5 && symmetry_order > 0
                % with 8-fold symmetry assumption of NPC
                tmpParticle.points = [tmpParticle.points; random_rotate_z(transform_by_rigid3d(M.points, parameter{j,i}), 2*pi/symmetry_order)];
                Particles{1,i}.points = random_rotate_z(transform_by_rigid3d(M.points, parameter{j,i}), 2*pi/symmetry_order);
            else
                % without 8-fold symmetry assumption of NPC
                tmpParticle.points = [tmpParticle.points; (transform_by_rigid3d(M.points, parameter{j,i}))];            
                Particles{1,i}.points = (transform_by_rigid3d(M.points, parameter{j,i}));
            end
            
            Particles{1,i}.sigma = M.sigma;
            tmpParticle.sigma = [tmpParticle.sigma; M.sigma];

            progress_bar(N*iter,j*N+i);
        end

        a = toc;
%         disp(['iter #' num2str(j) '... done in ' num2str(a) ' seconds']); 
        superParticle{j+1} = tmpParticle.points; 
        initParticle = tmpParticle;
        [density] = visualizeSMLM3D(superParticle{j+1}, 0.1, 0); % def=0.05
        weight = density/max(density);
    
    end
 
    % concatenate all previous registration parameters (not implemented)
    MT = zeros(4,4,N,iter);

    % save to disk
%     save([outdir '/superParticle'], 'superParticle');
    
%     disp('Bootstapping is done  !');
    
end