function three_particles()
% Example for 3Dalltoall, calling the fuse_particles_3d.m function
%
% The example loads some data and calls fuse_particles_3d. It should run
% through.
%
% Add the mex folder in the Build output directory (containing the mex and
% library files used by the Matlab code) as well as the Matlab project code
% (in the "MATLAB" folder) to the Matlab path before running this script.

% load example data
d = load('example_data.mat.data','-mat'); % *.mat is in gitignore
d = d.d;

% call to fuse_particles_3d
[transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters]...
    = fuse_particles_3d(numel(d.n_localizations_per_particle), d.n_localizations_per_particle, d.coordinates_x, d.coordinates_y, d.coordinates_z,...
    d.weights_xy, d.weights_z, d.channel_ids,...
    0, 1, 2, 0, 20);

end