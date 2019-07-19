#ifndef FUSE_PARTICLES_3D_INITIALIZE_WIN32_INCLUDED
#define FUSE_PARTICLES_3D_INITIALIZE_WIN32_INCLUDED

#include <string.h>

#ifdef _WIN32
#define LOAD_MCC_LIBRARY fuse_particles_3d_initialize_win32();
#else
#define LOAD_MCC_LIBRARY
#endif

// Global flag indicating that the Matlab runtime library has been started
extern int mcr_initialized;

// Global flag indicating that the MCC-generated dll has been initialized
extern int mcc_fuse_particles_3d_initialized;

#ifdef __cplusplus
extern "C" {
#endif

    int dummy_function(int argc, void *argv[]);
    int get_current_dll_path();
    int fuse_particles_3d_initialize_win32();
    int mcr_start();
    int mcr_stop();

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // !FUSE_PARTICLES_3D_INITIALIZE_WIN32_INCLUDED