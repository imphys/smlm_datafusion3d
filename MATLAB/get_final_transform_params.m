function parameters = get_final_transform_params(transformed_coordinates, coordinates)

% obtain the absolute transformations

[~, ~, p] = procrustes(...
    transformed_coordinates, ...
    coordinates,...
    'scaling', false,...
    'reflection', false);
p.c = p.c(1,:);

parameters = [p.T(:); p.c(:)];

%
% c = transform{i}.c; % c — Translation component
% T = transform{i}.T; % T — Orthogonal rotation

% reconstructed_super_particle = [];
% for i=1:N
%     reconstructed_super_particle = [reconstructed_super_particle;...
%         particles{i}.points * parameters{i}.T + parameters{i}.c];
% end

% for i=1:N
% 	sizen(i) = size(particles{i}.points,1);
% end
% 
% % crop initial particles from the super particle
% startIdx = 0;
% for i=1:N
% 	endIdx = startIdx+sizen(i)-1;
% 	finalParticles{i}.points = superParticle(startIdx+1:endIdx+1,:);
% 	startIdx = endIdx + 1;
% end
% 
% % obtain the absolute transformations
% for i=1:N
% 	[~, ~, parameters{i}] = procrustes(finalParticles{i}.points, ...
%     	particles{i}.points, 'scaling', false, 'reflection', false);
%     parameters{i}.c = parameters{i}.c(1,:);
% end

end