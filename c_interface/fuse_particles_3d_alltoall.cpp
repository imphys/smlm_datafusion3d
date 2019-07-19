#include "fuse_particles_3d.h"
#include "mcc_fuse_particles_3d.h"
#include "mex.h"
#include <stdlib.h>
#include "fuse_particles_3d_initialize.h"

// Global flag indicating that the Matlab runtime library has been started
extern int mcr_initialized;

// Global flag indicating that the MCC-generated dll has been initialized
extern int mcc_fuse_particles_3d_initialized;

int fuse_particles_3d_alltoall_(int argc, const char **argv)
{
    double * registration_matrix = (double *)argv[0];
    int32_t n_particles = *(int32_t *)argv[1];
    int32_t * n_localizations_per_particle = (int32_t *)argv[2];
    double * coordinates_x = (double *)argv[3];
    double * coordinates_y = (double *)argv[4];
    double * coordinates_z = (double *)argv[5];
    double * precision_xy = (double *)argv[6];
    double * precision_z = (double *)argv[7];
    double gauss_transform_scale = *(double *)argv[8];
    int32_t * channel_ids = (int *)argv[9];
    int32_t averaging_channel_id = *(int32_t *)argv[10];
    int32_t use_gpu = *(int32_t *)argv[11];

    // total number of localizations
    size_t n_localizations = 0;
    for (int i = 0; i < n_particles; i++)
        n_localizations += n_localizations_per_particle[i];

    // input
    mxArray * mx_n_particles = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_n_localizations_per_particle = mxCreateNumericMatrix(n_particles, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_coordinates_x = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_coordinates_y = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_coordinates_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_precision_xy = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_precision_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_gauss_transform_scale = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_use_gpu = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_channel_ids = mxCreateNumericMatrix(n_localizations, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_averaging_channel_id = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);

    // output
    mxArray * mx_registration_matrix = NULL;

    // copy input
    memcpy(mxGetPr(mx_n_particles), &n_particles, sizeof(int32_t));
    memcpy(mxGetPr(mx_n_localizations_per_particle), n_localizations_per_particle, n_particles * sizeof(int32_t));
    memcpy(mxGetPr(mx_coordinates_x), coordinates_x, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_y), coordinates_y, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_z), coordinates_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_precision_xy), precision_xy, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_precision_z), precision_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_gauss_transform_scale), &gauss_transform_scale, sizeof(double));
    memcpy(mxGetPr(mx_use_gpu), &use_gpu, sizeof(int32_t));
    memcpy(mxGetPr(mx_channel_ids), channel_ids, n_localizations * sizeof(int32_t));
    memcpy(mxGetPr(mx_averaging_channel_id), &averaging_channel_id, sizeof(int32_t));

    // initialize application

    if (mcc_fuse_particles_3d_initialized == 0)
    {
        mcc_fuse_particles_3d_initialized = (int) mcc_fuse_particles_3dInitialize();
    }

    if (mcc_fuse_particles_3d_initialized == 0)
    {
        fprintf(stderr, "Could not initialize the library.\n");
        return -2;
    }

    // run application
    mlfMcc_fuse_particles_3d_alltoall(
        1,
        &mx_registration_matrix,
        mx_n_particles,
        mx_n_localizations_per_particle,
        mx_coordinates_x,
        mx_coordinates_y,
        mx_coordinates_z,
        mx_precision_xy,
        mx_precision_z,
        mx_gauss_transform_scale,
        mx_channel_ids,
        mx_averaging_channel_id,
        mx_use_gpu);

    if (mx_registration_matrix == NULL)
    {
        fprintf(stderr, "Registration matrix not set in Matlab.\n");
        return -3;
    }

    memcpy(registration_matrix, mxGetPr(mx_registration_matrix), (n_particles * (n_particles-1)) / 2 * 7 * sizeof(double)); 

     // mcc_fuse_particles_3dTerminate();

    mxDestroyArray(mx_registration_matrix);

    mxDestroyArray(mx_n_particles);
    mxDestroyArray(mx_n_localizations_per_particle);
    mxDestroyArray(mx_coordinates_x);
    mxDestroyArray(mx_coordinates_y);
    mxDestroyArray(mx_coordinates_z);
    mxDestroyArray(mx_precision_xy);
    mxDestroyArray(mx_precision_z);
    mxDestroyArray(mx_gauss_transform_scale);
    mxDestroyArray(mx_channel_ids);
    mxDestroyArray(mx_averaging_channel_id);
    mxDestroyArray(mx_use_gpu);

    return 0;
}


int fuse_particles_3d_alltoall_portable(int argc, void *argv[])
{

    return fuse_particles_3d_alltoall(
        (double *) argv[0],
        *(int32_t *) argv[1],
        (int32_t *) argv[2],
        (double *) argv[3],
        (double *) argv[4],
        (double *) argv[5],
        (double *) argv[6],
        (double *) argv[7],
        *(double *)argv[8],
        (int32_t *) argv[9],
        *(int32_t *) argv[10], 
        *(int32_t *)argv[11]);

}


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
    int32_t * channel_ids,
    int32_t averaging_channel_id, 
    int32_t use_gpu)
{
    LOAD_MCC_LIBRARY

    const int argc = 12;
    const char * argv[argc];

    argv[0] = (char *)registration_matrix;
    argv[1] = (char *)(&n_particles);
    argv[2] = (char *)n_localizations_per_particle;
    argv[3] = (char *)coordinates_x;
    argv[4] = (char *)coordinates_y;
    argv[5] = (char *)coordinates_z;
    argv[6] = (char *)precision_xy;
    argv[7] = (char *)precision_z;
    argv[8] = (char *)(&gauss_transform_scale);
    argv[9] = (char *)channel_ids;
    argv[10] = (char *)(&averaging_channel_id);
    argv[11] = (char *)(&use_gpu);

    // initialize application
    if (!mcr_start())
    {
        fprintf(stderr, "Could not initialize the application.\n");
        return -1;
    }

    // run application
    int return_code_mcl_runmain = mclRunMain((mclMainFcnType)fuse_particles_3d_alltoall_, argc, argv);

    // stop the Matlab runtime library
    //int return_code_terminate = mcr_stop();

    return return_code_mcl_runmain;
}
