
function [transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters_out]...
    = fuse_particles_3d_onetoall(...
        n_particles,...
        n_localizations_per_particle,...
        coordinates_x,...
        coordinates_y,...
        coordinates_z,...
        transformation_parameters_in,...
        precision_xy,...
        precision_z,...
        gauss_render_width,...
        channel_ids,...
        averaging_channel_id,...
        symmetry_order,...
        USE_GPU)

%% check input parameters
if nargin < 12
    symmetry_order = 0;
    if nargin < 11
        averaging_channel_id = 0;
        if nargin == 10
            channel_ids(:) = 0;
        elseif nargin < 10
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

%% reshape transformation parameters
transformation_parameters_in = reshape(transformation_parameters_in,4,4,[]);

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

[tc,tp] = one2all3D(...
    particles,...
    [],...
    '.',...
    coordinates,...
    gauss_render_width,...
    symmetry_order,...
    USE_GPU_GAUSSTRANSFORM,...
    USE_GPU_EXPDIST);

coordinates(channel_filter,:) = tc{end};
fprintf([' ' num2str(toc(t)) ' s\n']);

%% transforming remaining channels
channel_filter = ~channel_filter;
transformation_parameters_out = zeros(size(transformation_parameters_in));
for i = 1:n_particles
    r = quaternion2rotation(tp{i})';
    t = tp{i}(5:7);
    transformation_parameters_out(1:3,1:3,i) = r;
    transformation_parameters_out(4,1:3,i) = t;
    transformation_parameters_out(4,4,i) = 1;

    indices = particle_beginnings(i):particle_endings(i);
    indices = indices(channel_filter(indices));

    coordinates(indices,:) = transform_coordinates([coordinates_x(indices), coordinates_y(indices), coordinates_z(indices)], r, t);
end

%% concatenate transformation parameters
for i=1:n_particles
    transformation_parameters_out(:,:,i)...
        = transformation_parameters_in(:,:,i)...
        * transformation_parameters_out(:,:,i);    
end

%% setting output arguments holding transformed coordinates
transformed_coordinates_x = coordinates(:,1);
transformed_coordinates_y = coordinates(:,2);
transformed_coordinates_z = coordinates(:,3);

end