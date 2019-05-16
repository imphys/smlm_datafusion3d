
function [transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters]...
    = fuse_particles_3d_onetoall(...
        n_particles,...
        n_localizations_per_particle,...
        coordinates_x,...
        coordinates_y,...
        coordinates_z,...
        precision_xy,...
        precision_z,...
        gauss_render_width,...
        channel_ids,...
        averaging_channel_id,...
        symmetry_order)

%% check input parameters
if nargin < 11
    symmetry_order = 0;
    if nargin < 10
        averaging_channel_id = 0;
        if nargin == 9
            channel_ids(:) = 0;
        elseif nargin < 9
            channel_ids = zeros(numel(coordinates_x),1);
        end
    end
end

USE_GPU_GAUSSTRANSFORM = false;
USE_GPU_EXPDIST = false;
if gpuDeviceCount > 0
    if exist('mex_gausstransform','file')
        USE_GPU_GAUSSTRANSFORM = true;
    end
    if exist('mex_expdist','file')
       USE_GPU_EXPDIST = true;
    end
end

%% setting indicies of the first localization of each particle
particle_beginnings = ones(n_particles,1);
particle_endings(n_particles,1) = numel(coordinates_x);
for i = 2:n_particles
    particle_beginnings(i) = particle_beginnings(i-1) + n_localizations_per_particle(i-1);
    particle_endings(i-1) = particle_beginnings(i)-1;
end

%% channel filter
channel_filter = channel_ids == averaging_channel_id;

%% assign coordinates to particles
for i=1:n_particles
    indices = particle_beginnings(i):particle_endings(i);
    indices = indices(channel_filter(indices));
    particles{1,i}.points = [coordinates_x(indices) coordinates_y(indices) coordinates_z(indices)];
    particles{1,i}.sigma = [precision_xy(indices), precision_z(indices)];
end

%% starting parallel pool
pp = gcp;
if ~(pp.Connected)
    parpool();
end

%% performing the one2all registration
pprint('one2all registration ',45);
t = tic;

coordinates = [coordinates_x(channel_filter) coordinates_y(channel_filter) coordinates_z(channel_filter)];
precision = [precision_xy(channel_filter) precision_z(channel_filter)];

tc = one2all3D(...
    particles,...
    [],...
    '.',...
    coordinates,...
    gauss_render_width,...
    symmetry_order,...
    USE_GPU_GAUSSTRANSFORM,...
    USE_GPU_EXPDIST);

coordinates(channel_ids == averaging_channel_id,:) = tc{end};
fprintf([' ' num2str(toc(t)) ' s\n']);

%% calculationg final transformation parameters
for i = 1:n_particles
    
    indices = particle_beginnings(i):particle_beginnings(i)+n_localizations_per_particle(i)-1;
    indices = indices(channel_ids(indices) == averaging_channel_id);
        
    transformation_parameters((i-1)*12+1:(i-1)*12+12,1) = get_final_transform_params(...
        coordinates(indices,:),...
        [coordinates_x(indices), coordinates_y(indices), coordinates_z(indices)]);
end

%% transforming remaining channels
for ch = 0:max(channel_ids)
    
    if ch == averaging_channel_id
        continue;
    end
    
    filter_channel = channel_ids == ch;
    
    for i = 1:n_particles
        tp.rot = reshape(transformation_parameters((i-1)*12+1:(i-1)*12+9),3,3);
        tp.shift = transformation_parameters((i-1)*12+10:(i-1)*12+12)';
        
        indices = particle_beginnings(i):particle_beginnings(i)+n_localizations_per_particle(i)-1;
        indices = indices(filter_channel(indices));
        
        coordinates(indices,:) = transform_coordinates([coordinates_x(indices), coordinates_y(indices), coordinates_z(indices)], tp.rot, tp.shift);
    end
end

%% setting output arguments holding transformed coordinates
transformed_coordinates_x = coordinates(:,1);
transformed_coordinates_y = coordinates(:,2);
transformed_coordinates_z = coordinates(:,3);

end