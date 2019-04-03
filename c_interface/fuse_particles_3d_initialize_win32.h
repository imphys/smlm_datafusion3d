#ifndef FUSE_PARTICLES_3D
#define FUSE_PARTICLES_3D

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

    int fuse_particles_3d_initialize_win32(int argc, void *argv[]);

    int fuse_particles_3d_initialize_win32_portable(int argc, void *argv[]);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // !FUSE_PARTICLES_3D