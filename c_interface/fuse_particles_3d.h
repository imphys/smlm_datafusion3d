
#include <string.h>

int fuse_particles_3d_portable(int argc, const char **argv);

int fuse_particles_3d(
    double * transformed_coordinates_x,
    double * transformed_coordinates_y,
    double * transformed_coordinates_z,
    double * transformation_parameters,
    int n_particles,
    int * n_localizations_per_particle,
    double * coordinates_x,
    double * coordinates_y,
    double * coordinates_z,
    double * weights_xy,
    double * weights_z,
    int * channel_ids,
    int averaging_channel_id,
    int n_iterations_alltoall,
    int n_iterations_onetoall,
    int symmetry_order);