#ifndef FUSE_PARTICLES_3D_ALLTOALL
#define FUSE_PARTICLES_3D_ALLTOALL

#include <string.h>
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

    int mcr_start();

    int mcr_stop();

    int fuse_particles_3d_alltoall_(int argc, const char **argv);

    int fuse_particles_3d_refinement_(int argc, const char **argv);
    
    int fuse_particles_3d_onetoall_(int argc, const char **argv);

    int fuse_particles_3d_alltoall_portable(int argc, void *argv[]);
    
    int fuse_particles_3d_refinement_portable(int argc, void *argv[]);
    
    int fuse_particles_3d_onetoall_portable(int argc, void *argv[]);

    int fuse_particles_3d_alltoall(
        double * registration_matrix,
        int32_t n_particles,
        int32_t * n_localizations_per_particle,
        double * coordinates_x,
        double * coordinates_y,
        double * coordinates_z,
        double * precision_xy,
        double * precision_z,
        double gauss_transform_scale,
        int32_t use_gpu,
        int32_t * channel_ids,
        int32_t averaging_channel_id);

    int fuse_particles_3d_refinement(
        double * transformed_coordinates_x,
        double * transformed_coordinates_y,
        double * transformed_coordinates_z,
        double * transformation_parameters,
        int32_t n_particles,
        int32_t * n_localizations_per_particle,
        double * registration_matrix,
        double * coordinates_x,
        double * coordinates_y,
        double * coordinates_z,
        double transformation_refinement_threshold);
    
    int fuse_particles_3d_onetoall(
        double * transformed_coordinates_x,
        double * transformed_coordinates_y,
        double * transformed_coordinates_z,
        double * transformation_parameters_out,
        int32_t n_particles,
        int32_t * n_localizations_per_particle,
        double * coordinates_x,
        double * coordinates_y,
        double * coordinates_z,
        double * transformation_parameters_in,
        double * precision_xy,
        double * precision_z,
        double gauss_render_width,
        int32_t use_gpu,
        int32_t * channel_ids,
        int32_t averaging_channel_id,
        int32_t symmetry_order);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // !FUSE_PARTICLES_3D_ALLTOALL