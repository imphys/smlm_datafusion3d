
#include "fuse_particles_3d.h"
#include "mcc_fuse_particles_3d.h"
#include "mex.h"

int fuse_particles_3d_(int argc, const char **argv)
{
    double * transformed_coordinates_x = (double *)argv[0];
    double * transformed_coordinates_y = (double *)argv[1];
    double * transformed_coordinates_z = (double *)argv[2];
    double * transformation_parameters = (double *)argv[3];
    int n_particles = (int) *argv[4];
    int * n_localizations_per_particle = (int*)argv[5];
    double * coordinates_x = (double *)argv[6];
    double * coordinates_y = (double *)argv[7];
    double * coordinates_z = (double *)argv[8];
    double * weights_xy = (double *)argv[9];
    double * weights_z = (double *)argv[10];
    int * channel_ids = (int *)argv[11];
    int averaging_channel_id = (int)*argv[12];
    int n_iterations_alltoall = (int)*argv[13];
    int n_iterations_onetoall = (int)*argv[14];
    int symmetry_order = (int)*argv[15];

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

    // output
    mxArray * mx_transformed_coordinates_x = NULL;
    mxArray * mx_transformed_coordinates_y = NULL;
    mxArray * mx_transformed_coordinates_z = NULL;
    mxArray * mx_transformation_parameters = NULL;

    // copy input
    memcpy(mxGetPr(mx_n_particles), &n_particles, sizeof(int));
    memcpy(mxGetPr(mx_n_localizations_per_particle), n_localizations_per_particle, n_particles * sizeof(int));
    memcpy(mxGetPr(mx_coordinates_x), coordinates_x, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_y), coordinates_y, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_coordinates_z), coordinates_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_weights_xy), weights_xy, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_weights_z), weights_z, n_localizations * sizeof(double));
    memcpy(mxGetPr(mx_channel_ids), channel_ids, n_localizations * sizeof(int));
    memcpy(mxGetPr(mx_averaging_channel_id), &averaging_channel_id, sizeof(int));
    memcpy(mxGetPr(mx_n_iterations_all2all), &n_iterations_alltoall, sizeof(int));
    memcpy(mxGetPr(mx_n_iterations_one2all), &n_iterations_onetoall, sizeof(int));
    memcpy(mxGetPr(mx_symmetry_order), &symmetry_order, sizeof(int));

    // initialize application
    if (!mcc_fuse_particles_3dInitialize()) {
        fprintf(stderr, "Could not initialize the library.\n");
        return -2;
    }
    else
    {
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
            mx_symmetry_order);

        memcpy(transformed_coordinates_x, mxGetPr(mx_transformed_coordinates_x), n_localizations * sizeof(double));
        memcpy(transformed_coordinates_y, mxGetPr(mx_transformed_coordinates_y), n_localizations * sizeof(double));
        memcpy(transformed_coordinates_z, mxGetPr(mx_transformed_coordinates_z), n_localizations * sizeof(double));
        memcpy(transformation_parameters, mxGetPr(mx_transformation_parameters), 12 * n_particles * sizeof(double));

        mcc_fuse_particles_3dTerminate();
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
    }

    return 0;
}

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
    int symmetry_order)
{
    const char *argv[16];

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

    // initialize application
    if (!mclInitializeApplication(NULL, 0))
    {
        fprintf(stderr, "Could not initialize the application.\n");
        return -1;
    }

    // run application
    return mclRunMain((mclMainFcnType)fuse_particles_3d_, 16, argv);

    // terminate application
    mclTerminateApplication();

    return 0;
}