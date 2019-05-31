
function [transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z,transformation_parameters]...
    = fuse_particles_3d_refinement(...
        n_particles,...
        n_localizations_per_particle,...
        registration_matrix,...
        coordinates_x,...
        coordinates_y,...
        coordinates_z,...
        transformation_refinement_threshold)

%% setting indicies of the first localization of each particle
n_localizations = numel(coordinates_x);
particle_beginnings = ones(n_particles,1);
particle_endings(n_particles,1) = n_localizations;
for i = 2:n_particles
    particle_beginnings(i) = particle_beginnings(i-1) + n_localizations_per_particle(i-1);
    particle_endings(i-1) = particle_beginnings(i) - 1;
end

%% starting parallel pool
pp = gcp;
if ~(pp.Connected)
    parpool();
end

%% translating quaternion to matrix representation (SE3)
k = 1;
RR = zeros(4,4,n_particles*(n_particles-1)/2);
I = zeros(2,n_particles*(n_particles-1)/2);
registration_matrix = reshape(registration_matrix,7,[]);
for i=1:n_particles-1
    
    matrix_index_i = size(registration_matrix,2) - ((n_particles-i+1)*(n_particles-i))/2 - i;
    
    for j=i+1:n_particles
        
        parameters = registration_matrix(:,matrix_index_i + j);
        
        q = [parameters(4) parameters(1) parameters(2) parameters(3)];
         
        % RR holds the registration parameters of size 4x4xn_particles(n_particles-1)/2 
        RR(1:3,1:3,k) = q2R(q);
        RR(1:3,4,k) = [parameters(5); parameters(6); parameters(7)];
        RR(4,4,k) = 1;
        RR(4,1:3) = 0;
        
        % I holds the connectivity of pairs of size 2xn_particles(n_particles-1)/2
        I(:,k)= [i;j];
        k=k+1;
    end
end

%% averaging transformation parameters
pprint('averaging transformation parameters ',45);
t = tic;
transformation_parameters = MeanSE3Graph(RR, I);
progress_bar(1,1);
fprintf([' ' num2str(toc(t)) ' s\n']);

%% remove outliers
pprint('removing outliers ',45);
t = tic;
[RR, I] = remove_outliers(RR, I, transformation_parameters, transformation_refinement_threshold);
progress_bar(1,1);
fprintf([' ' num2str(toc(t)) ' s\n']);

%% repeating averaging transformation parameters
pprint('averaging transformation parameters ',45);
t = tic;
transformation_parameters = MeanSE3Graph(RR, I);
progress_bar(1,1);
fprintf([' ' num2str(toc(t)) ' s\n']);

%% applying the absolute registration parameters to particles
pprint('coordinate transformation ',45);
t = tic;
transformed_coordinates_x = coordinates_x;
transformed_coordinates_y = coordinates_y;
transformed_coordinates_z = coordinates_z;
for i=1:n_particles  
    
    indices = particle_beginnings(i):particle_endings(i);
    coordinates = [coordinates_x(indices), coordinates_y(indices), coordinates_z(indices)];
    
    estA = eye(4);
    estA(1:3,1:3) = transformation_parameters(1:3,1:3,i); 
    estA(4,:) = transformation_parameters(:,4,i)';
    estTform = invert(affine3d(estA));
    transformation_parameters(:,:,i) = estTform.T;
    
    % transform coordinates
    coordinates_ptc = pointCloud(coordinates);
    transformed_coordinates_ptc = pctransform2(coordinates_ptc, estTform);
    
    % copy transformed coordinates
    transformed_coordinates_x(indices) = transformed_coordinates_ptc.Location(:,1);
    transformed_coordinates_y(indices) = transformed_coordinates_ptc.Location(:,2);
    transformed_coordinates_z(indices) = transformed_coordinates_ptc.Location(:,3);
end
progress_bar(1,1);
fprintf([' ' num2str(toc(t)) ' s\n']);

end