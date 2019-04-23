#ifndef FUSE_PARTICLES_3D
#define FUSE_PARTICLES_3D

#include <string.h>
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

    int mcr_start();

    int mcr_stop();

    int get_mcr_initialized();

    int fuse_particles_3d_(int argc, const char **argv);

    int fuse_particles_3d_portable(int argc, void *argv[]);

    int fuse_particles_3d(
        double * transformed_coordinates_x,
        double * transformed_coordinates_y,
        double * transformed_coordinates_z,
        double * transformation_parameters,
        int32_t n_particles,
        int32_t * n_localizations_per_particle,
        double * coordinates_x,
        double * coordinates_y,
        double * coordinates_z,
        double * weights_xy,
        double * weights_z,
        int32_t * channel_ids,
        int32_t averaging_channel_id,
        int32_t n_iterations_alltoall,
        int32_t n_iterations_onetoall,
        int32_t symmetry_order,
        double outlier_threshold);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // !FUSE_PARTICLES_3D