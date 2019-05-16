#include "fuse_particles_3d.h"
#include "mcc_fuse_particles_3d.h"
#include "mex.h"
#include <stdlib.h>
#include "fuse_particles_3d_initialize.h"

// Global flag indicating that the Matlab runtime library has been started
extern int mcr_initialized;

// Global flag indicating that the MCC-generated dll has been initialized
extern int mcc_fuse_particles_3d_initialized;

int fuse_particles_3d_refinement_(int argc, const char **argv)
{
    double * transformed_coordinates_x = (double *)argv[0];
    double * transformed_coordinates_y = (double *)argv[1];
    double * transformed_coordinates_z = (double *)argv[2];
    int32_t n_particles = *(int32_t *)argv[3];
    int32_t * n_localizations_per_particle = (int32_t *)argv[4];
    double * registration_matrix = (double *)argv[5];
    double * coordinates_x = (double *)argv[6];
    double * coordinates_y = (double *)argv[7];
    double * coordinates_z = (double *)argv[8];
    double transformation_refinement_threshold = *(double *)argv[9];
    int32_t * channel_ids = (int *)argv[10];
    int32_t averaging_channel_id = *(int32_t *)argv[11];

    // total number of localizations
    size_t n_localizations = 0;
    for (int i = 0; i < n_particles; i++)
        n_localizations += n_localizations_per_particle[i];

    // size of registration_matrix
    size_t matrix_size = (n_particles * (n_particles - 1)) / 2 * 7;

    // input
    mxArray * mx_n_particles = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_n_localizations_per_particle = mxCreateNumericMatrix(n_particles, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_registration_matrix = mxCreateNumericMatrix(matrix_size, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_coordinates_x = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_coordinates_y = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_coordinates_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_transformation_refinement_threshold = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_channel_ids = mxCreateNumericMatrix(n_localizations, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_averaging_channel_id = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);

    // output
    mxArray * mx_transformed_coordinates_x = NULL;
    mxArray * mx_transformed_coordinates_y = NULL;
    mxArray * mx_transformed_coordinates_z = NULL;

    // copy input
    memcpy(mxGetPr(mx_n_particles), &n_particles, sizeof(int32_t));
    memcpy(mxGetPr(mx_n_localizations_per_particle), n_localizations_per_particle, n_particles * sizeof(int32_t));
    memcpy(mxGetPr(mx_registration_matrix), registration_matrix, matrix_size * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_x), coordinates_x, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_y), coordinates_y, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_z), coordinates_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_transformation_refinement_threshold), &transformation_refinement_threshold, sizeof(double));
    memcpy(mxGetPr(mx_channel_ids), channel_ids, n_localizations * sizeof(int32_t));
    memcpy(mxGetPr(mx_averaging_channel_id), &averaging_channel_id, sizeof(int32_t));

    // initialize application

    if (mcc_fuse_particles_3d_initialized == 0)
    {
        mcc_fuse_particles_3d_initialized = (int)mcc_fuse_particles_3dInitialize();
    }

    if (mcc_fuse_particles_3d_initialized == 0)
    {
        fprintf(stderr, "Could not initialize the library.\n");
        return -2;
    }

    // run application
    mlfMcc_fuse_particles_3d_refinement(
        3,
        &mx_transformed_coordinates_x,
        &mx_transformed_coordinates_y,
        &mx_transformed_coordinates_z,
        mx_n_particles,
        mx_n_localizations_per_particle,
        mx_registration_matrix,
        mx_coordinates_x,
        mx_coordinates_y,
        mx_coordinates_z,
        mx_transformation_refinement_threshold,
        mx_channel_ids,
        mx_averaging_channel_id);

    if (mx_transformed_coordinates_x == NULL ||
        mx_transformed_coordinates_y == NULL ||
        mx_transformed_coordinates_z == NULL)
    {
        fprintf(stderr, "Not all outputs set in Matlab.\n");
        return -3;
    }

    memcpy(transformed_coordinates_x, mxGetPr(mx_transformed_coordinates_x), n_localizations * sizeof(double));
    memcpy(transformed_coordinates_y, mxGetPr(mx_transformed_coordinates_y), n_localizations * sizeof(double));
    memcpy(transformed_coordinates_z, mxGetPr(mx_transformed_coordinates_z), n_localizations * sizeof(double));

    // mcc_fuse_particles_3dTerminate();

    mxDestroyArray(mx_transformed_coordinates_x);
    mxDestroyArray(mx_transformed_coordinates_y);
    mxDestroyArray(mx_transformed_coordinates_z);

    mxDestroyArray(mx_n_particles);
    mxDestroyArray(mx_n_localizations_per_particle);
    mxDestroyArray(mx_registration_matrix);
    mxDestroyArray(mx_coordinates_x);
    mxDestroyArray(mx_coordinates_y);
    mxDestroyArray(mx_coordinates_z);
    mxDestroyArray(mx_transformation_refinement_threshold);
    mxDestroyArray(mx_channel_ids);
    mxDestroyArray(mx_averaging_channel_id);

    return 0;
}


int fuse_particles_3d_refinement_portable(int argc, void *argv[])
{

    return fuse_particles_3d_refinement(
        (double *)argv[0],
        (double *)argv[1],
        (double *)argv[2],
        *(int32_t *)argv[3],
        (int32_t *)argv[4],
        (double *)argv[5],
        (double *)argv[6],
        (double *)argv[7],
        (double *)argv[8],
        *(double *)argv[9],
        (int32_t *)argv[10],
        *(int32_t *)argv[11]);

}


int fuse_particles_3d_refinement(
    double * transformed_coordinates_x,
    double * transformed_coordinates_y,
    double * transformed_coordinates_z,
    int32_t n_particles,
    int32_t * n_localizations_per_particle,
    double * registration_matrix,
    double * coordinates_x,
    double * coordinates_y,
    double * coordinates_z,
    double transformation_refinement_threshold,
    int32_t * channel_ids,
    int32_t averaging_channel_id)
{
    LOAD_MCC_LIBRARY

    const int argc = 12;
    const char * argv[argc];

    argv[0] = (char *)transformed_coordinates_x;
    argv[1] = (char *)transformed_coordinates_y;
    argv[2] = (char *)transformed_coordinates_z;
    argv[3] = (char *)(&n_particles);
    argv[4] = (char *)n_localizations_per_particle;
    argv[5] = (char *)registration_matrix;
    argv[6] = (char *)coordinates_x;
    argv[7] = (char *)coordinates_y;
    argv[8] = (char *)coordinates_z;
    argv[9] = (char *)(&transformation_refinement_threshold);
    argv[10] = (char *)channel_ids;
    argv[11] = (char *)(&averaging_channel_id);

    // initialize application
    if (!mcr_start())
    {
        fprintf(stderr, "Could not initialize the application.\n");
        return -1;
    }

    // run application
    int return_code_mcl_runmain = mclRunMain((mclMainFcnType)fuse_particles_3d_refinement_, argc, argv);

    // stop the Matlab runtime library
    //int return_code_terminate = mcr_stop();

    return return_code_mcl_runmain;
}
