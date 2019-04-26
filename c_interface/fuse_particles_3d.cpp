#include "fuse_particles_3d.h"
#include "mcc_fuse_particles_3d.h"
#include "mex.h"
#include <stdlib.h>

#ifdef _WIN32
    #include "fuse_particles_3d_initialize_win32.h"
    #define LOAD_MCC_LIBRARY fuse_particles_3d_initialize_win32();
#else
    #define LOAD_MCC_LIBRARY
#endif

// Global flag indicating that the Matlab runtime library has been started
int mcr_initialized = 0;

// Global flag indicating that the MCC-generated dll has been initialized
int mcc_fuse_particles_3d_initialized = 0;


int mcr_start()
{
    if (mcr_initialized == 0)
    {
        mclInitializeApplication(NULL, 0);
        mcr_initialized = (int) mclIsMCRInitialized();
    }
    return mcr_initialized;
}


int mcr_stop()
{
    if (mcr_initialized == 1)
    {
        mclTerminateApplication();
        mcr_initialized = (int)mclIsMCRInitialized();
    }
    return mcr_initialized;
}



int fuse_particles_3d_(int argc, const char **argv)
{
    double * transformed_coordinates_x = (double *)argv[0];
    double * transformed_coordinates_y = (double *)argv[1];
    double * transformed_coordinates_z = (double *)argv[2];
    double * transformation_parameters = (double *)argv[3];
    int32_t n_particles = *(int32_t *)argv[4];
    int32_t * n_localizations_per_particle = (int32_t *)argv[5];
    double * coordinates_x = (double *)argv[6];
    double * coordinates_y = (double *)argv[7];
    double * coordinates_z = (double *)argv[8];
    double * weights_xy = (double *)argv[9];
    double * weights_z = (double *)argv[10];
    int32_t * channel_ids = (int *)argv[11];
    int32_t averaging_channel_id = *(int32_t *)argv[12];
    int32_t n_iterations_alltoall = *(int32_t *)argv[13];
    int32_t n_iterations_onetoall = *(int32_t *)argv[14];
    int32_t symmetry_order = *(int32_t *)argv[15];
    double outlier_threshold = *(double *)argv[16];

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
    mxArray * mx_weights_xy = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_weights_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
    mxArray * mx_channel_ids = mxCreateNumericMatrix(n_localizations, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_averaging_channel_id = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_n_iterations_all2all = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_n_iterations_one2all = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_symmetry_order = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxArray * mx_outlier_threshold = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);

    // output
    mxArray * mx_transformed_coordinates_x = NULL;
    mxArray * mx_transformed_coordinates_y = NULL;
    mxArray * mx_transformed_coordinates_z = NULL;
    mxArray * mx_transformation_parameters = NULL;


    // copy input
    memcpy(mxGetPr(mx_n_particles), &n_particles, sizeof(int32_t));
    memcpy(mxGetPr(mx_n_localizations_per_particle), n_localizations_per_particle, n_particles * sizeof(int32_t));
    memcpy(mxGetPr(mx_coordinates_x), coordinates_x, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_y), coordinates_y, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_z), coordinates_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_weights_xy), weights_xy, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_weights_z), weights_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_channel_ids), channel_ids, n_localizations * sizeof(int32_t));
    memcpy(mxGetPr(mx_averaging_channel_id), &averaging_channel_id, sizeof(int32_t));
    memcpy(mxGetPr(mx_n_iterations_all2all), &n_iterations_alltoall, sizeof(int32_t));
    memcpy(mxGetPr(mx_n_iterations_one2all), &n_iterations_onetoall, sizeof(int32_t));
    memcpy(mxGetPr(mx_symmetry_order), &symmetry_order, sizeof(int32_t));
    memcpy(mxGetPr(mx_outlier_threshold), &outlier_threshold, sizeof(double));


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
    mlfMcc_fuse_particles_3d(
        4,
        &mx_transformed_coordinates_x,
        &mx_transformed_coordinates_y,
        &mx_transformed_coordinates_z,
        &mx_transformation_parameters,
        mx_n_particles,
        mx_n_localizations_per_particle,
        mx_coordinates_x,
        mx_coordinates_y,
        mx_coordinates_z,
        mx_weights_xy,
        mx_weights_z,
        mx_channel_ids,
        mx_averaging_channel_id,
        mx_n_iterations_all2all,
        mx_n_iterations_one2all,
        mx_symmetry_order,
        mx_outlier_threshold);

    if (mx_transformed_coordinates_x == NULL || mx_transformed_coordinates_y == NULL ||
        mx_transformed_coordinates_z == NULL || mx_transformation_parameters == NULL)
    {
        fprintf(stderr, "Not all outputs set in Matlab.\n");
        return -3;
    }

    memcpy(transformed_coordinates_x, mxGetPr(mx_transformed_coordinates_x), n_localizations * sizeof(double));
    memcpy(transformed_coordinates_y, mxGetPr(mx_transformed_coordinates_y), n_localizations * sizeof(double));
    memcpy(transformed_coordinates_z, mxGetPr(mx_transformed_coordinates_z), n_localizations * sizeof(double));
    memcpy(transformation_parameters, mxGetPr(mx_transformation_parameters), 12 * n_particles * sizeof(double));    

    // mcc_fuse_particles_3dTerminate();

    mxDestroyArray(mx_transformed_coordinates_x);
    mxDestroyArray(mx_transformed_coordinates_y);
    mxDestroyArray(mx_transformed_coordinates_z);
    mxDestroyArray(mx_transformation_parameters);

    mxDestroyArray(mx_n_particles);
    mxDestroyArray(mx_n_localizations_per_particle);
    mxDestroyArray(mx_coordinates_x);
    mxDestroyArray(mx_coordinates_y);
    mxDestroyArray(mx_coordinates_z);
    mxDestroyArray(mx_weights_xy);
    mxDestroyArray(mx_weights_z);
    mxDestroyArray(mx_channel_ids);
    mxDestroyArray(mx_averaging_channel_id);
    mxDestroyArray(mx_n_iterations_all2all);
    mxDestroyArray(mx_n_iterations_one2all);
    mxDestroyArray(mx_symmetry_order);
    mxDestroyArray(mx_outlier_threshold);

    return 0;
}


int fuse_particles_3d_portable(int argc, void *argv[])
{

    return fuse_particles_3d(
        (double *) argv[0], 
        (double *) argv[1],
        (double *) argv[2],
        (double *) argv[3],
        *(int32_t *) argv[4],
        (int32_t *) argv[5],
        (double *) argv[6],
        (double *) argv[7],
        (double *) argv[8],
        (double *) argv[9],
        (double *) argv[10],
        (int32_t *) argv[11],
        *(int32_t *) argv[12],
        *(int32_t *) argv[13],
        *(int32_t *) argv[14],
        *(int32_t *) argv[15],
        *(double *) argv[16]);

}


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
    double outlier_threshold)
{
    LOAD_MCC_LIBRARY

    const int argc = 17;
    const char * argv[17];

    argv[0] = (char *)transformed_coordinates_x;
    argv[1] = (char *)transformed_coordinates_y;
    argv[2] = (char *)transformed_coordinates_z;
    argv[3] = (char *)transformation_parameters;
    argv[4] = (char *)(&n_particles);
    argv[5] = (char *)n_localizations_per_particle;
    argv[6] = (char *)coordinates_x;
    argv[7] = (char *)coordinates_y;
    argv[8] = (char *)coordinates_z;
    argv[9] = (char *)weights_xy;
    argv[10] = (char *)weights_z;
    argv[11] = (char *)channel_ids;
    argv[12] = (char *)(&averaging_channel_id);
    argv[13] = (char *)(&n_iterations_alltoall);
    argv[14] = (char *)(&n_iterations_onetoall);
    argv[15] = (char *)(&symmetry_order);
    argv[16] = (char *)(&outlier_threshold);


    if (mcr_initialized == 0)
    {
        // initialize application
        if (!mcr_start())
        {
            fprintf(stderr, "Could not initialize the application.\n");
            return -1;
        }
    }

    // run application
    int return_code_mcl_runmain = mclRunMain((mclMainFcnType)fuse_particles_3d_, argc, argv);

    // stop the Matlab runtime library
    //int return_code_terminate = mcr_stop();

    return return_code_mcl_runmain;
}
