function registration_matrix...
    = fuse_particles_3d_alltoall(...
        n_particles,...
        n_localizations_per_particle,...
        coordinates_x,...
        coordinates_y,...
        coordinates_z,...
        precision_xy,...
        precision_z,...
        gauss_transform_scale,...
        channel_ids,...
        averaging_channel_id,...
        USE_GPU)

%% GPU flags
USE_GPU_EXPDIST = USE_GPU;
USE_GPU_GAUSSTRANSFORM = USE_GPU;

if gpuDeviceCount <= 0
    USE_GPU_GAUSSTRANSFORM = false;
    USE_GPU_EXPDIST = false;
end

if USE_GPU_GAUSSTRANSFORM 
    if ~exist('mex_gausstransform','file')
        USE_GPU_GAUSSTRANSFORM = false;
    end
end
    
if USE_GPU_EXPDIST 
    if ~exist('mex_expdist','file')
        USE_GPU_EXPDIST = false;
    end
end

if ~USE_GPU_GAUSSTRANSFORM
    if ~exist('mex_gausstransform_cpu','file')
        message = 'No compiled modules found for GaussTransform.\n';
        message_id = 'MATLAB:MEXNotFound';
        error (message_id, message);
    end
    fprintf('running CPU version of gausstransform\n')
else
    fprintf('running GPU version of gausstransform\n')
end

if ~USE_GPU_EXPDIST 
    if ~exist('mex_expdist_cpu','file')
        message = 'No compiled modules found for ExpDist.\n';
        message_id = 'MATLAB:MEXNotFound';
        error (message_id, message);
    end
    fprintf('running CPU version of expdist\n')
else
    fprintf('running GPU version of expdist\n')
end

%% starting parallel pool
pp = gcp;
if ~(pp.Connected)
    parpool();
end

%% filtering localization by averaging channel ID
channel_filter = channel_ids == averaging_channel_id;

%% setting indicies of the first localization of each particle
particle_beginnings = ones(n_particles,1);
particle_endings(n_particles,1) = numel(coordinates_x);
for i = 2:n_particles
    particle_beginnings(i) = particle_beginnings(i-1) + n_localizations_per_particle(i-1);
    particle_endings(i-1) = particle_beginnings(i) - 1;
end

%% performing the all2all registration
pprint('all2all registration ',45)
t = tic;
matrix_size = ((n_particles-1)*n_particles)/2;
registration_matrix = zeros(7,matrix_size);
coordinates_j = cell(n_particles,1);
precision_j = cell(n_particles,1);
for i=1:n_particles-1
    
    indices_i = particle_beginnings(i):particle_endings(i);
    indices_i = indices_i(channel_filter(indices_i));
    coordinates_i = [coordinates_x(indices_i), coordinates_y(indices_i), coordinates_z(indices_i)];
    precision_i = [precision_xy(indices_i), precision_z(indices_i)];
    
    matrix_index_i = matrix_size - ((n_particles-i+1)*(n_particles-i))/2 - i;
    
    for j=i+1:n_particles
        indices_j = particle_beginnings(j):particle_endings(j);
        coordinates_j{j} = [coordinates_x(indices_j), coordinates_y(indices_j), coordinates_z(indices_j)];
        precision_j{j} = [precision_xy(indices_j), precision_z(indices_j)];
    end
    
    parfor j=i+1:n_particles
        
        registration_matrix(:,matrix_index_i + j)...
            = all2all3Dn(coordinates_i, coordinates_j{j}, precision_i, precision_j{j},gauss_transform_scale,[], USE_GPU_GAUSSTRANSFORM, USE_GPU_EXPDIST)';
    end
    
    progress_bar(n_particles-1,i);
end
fprintf([' ' num2str(toc(t)) ' s\n']);

end