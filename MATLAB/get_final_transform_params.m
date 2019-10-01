function [finalParticles, transform] = get_final_transform_params(xSuperParticle, subParticles)

% obtain the absolute transformations

    N = numel(subParticles);        % number of particles
    finalParticles = cell(1,N);     % the final aligned particles
    sizen = zeros(1,N);             % size of each particle
    
    % particle size
    for i=1:N
        sizen(i) = size(subParticles{1,i}.points,1);
    end

    % crop initial particles from the super particle
    startIdx = 0;
    for i=1:N
        endIdx = startIdx+sizen(i)-1;
        finalParticles{1,i}.points = xSuperParticle(startIdx+1:endIdx+1,:);
        startIdx = endIdx + 1;
    end

    % obtain the absolute transformations
    for i=1:N
        [~, ~, transform{i}] = procrustes(finalParticles{1,i}.points, ...
            subParticles{1,i}.points, 'scaling', false, 'reflection', false);    
    end

end