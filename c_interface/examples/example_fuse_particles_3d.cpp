#include <iostream>
#include <vector>
#include "fuse_particles_3d.h"
#include "data.h"

//int example_fuse_particles_3d(int argc, char const *argv[])
//{
//    int const n_particles = 2;
//    std::vector<int> n_localizations_per_particle = N_LOCALIZATIONS_PER_PARTICLE;
//    std::vector<double> coordinates_x = COORDINATES_X;
//    std::vector<double> coordinates_y = COORDINATES_Y;
//    std::vector<double> coordinates_z = COORDINATES_Z;
//    std::vector<double> weights_xy = WEIGHTS_XY;
//    std::vector<double> weights_z = WEIGHTS_Z;
//    std::vector<int> channel_ids = CHANNEL_IDS;
//    int averaging_channel_id = 0;
//    int n_iterations_alltoall = 1;
//    int n_iterations_onetoall = 2;
//    int symmetry_order = 0;
//
//    std::size_t const n_localizations = n_localizations_per_particle[0] + n_localizations_per_particle[1];
//
//    // input
//    mxArray * mx_n_particles = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_n_localizations_per_particle = mxCreateNumericMatrix(n_particles, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_coordinates_x = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
//    mxArray * mx_coordinates_y = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
//    mxArray * mx_coordinates_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
//    mxArray * mx_weights_xy = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
//    mxArray * mx_weights_z = mxCreateNumericMatrix(n_localizations, 1, mxDOUBLE_CLASS, mxREAL);
//    mxArray * mx_channel_ids = mxCreateNumericMatrix(n_localizations, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_averaging_channel_id = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_n_iterations_all2all = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_n_iterations_one2all = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
//    mxArray * mx_symmetry_order = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
//
//    // output
//    mxArray * transformed_coordinates_x = NULL;
//    mxArray * transformed_coordinates_y = NULL;
//    mxArray * transformed_coordinates_z = NULL;
//    mxArray * transformation_parameters = NULL;
//
//    // copy input
//    memcpy(mxGetPr(mx_n_particles), &n_particles, sizeof(int));
//    memcpy(mxGetPr(mx_n_localizations_per_particle), n_localizations_per_particle.data(), n_particles * sizeof(int));
//    memcpy(mxGetPr(mx_coordinates_x), coordinates_x.data(), n_localizations * sizeof(double));
//    memcpy(mxGetPr(mx_coordinates_y), coordinates_y.data(), n_localizations * sizeof(double));
//    memcpy(mxGetPr(mx_coordinates_z), coordinates_z.data(), n_localizations * sizeof(double));
//    memcpy(mxGetPr(mx_weights_xy), weights_xy.data(), n_localizations * sizeof(double));
//    memcpy(mxGetPr(mx_weights_z), weights_z.data(), n_localizations * sizeof(double));
//    memcpy(mxGetPr(mx_channel_ids), channel_ids.data(), n_localizations * sizeof(int));
//    memcpy(mxGetPr(mx_averaging_channel_id), &averaging_channel_id, sizeof(int));
//    memcpy(mxGetPr(mx_n_iterations_all2all), &n_iterations_alltoall, sizeof(int));
//    memcpy(mxGetPr(mx_n_iterations_one2all), &n_iterations_onetoall, sizeof(int));
//    memcpy(mxGetPr(mx_symmetry_order), &symmetry_order, sizeof(int));
//
//    // run
//    if (!mcc_fuse_particles_3dInitialize()) {
//        fprintf(stderr, "Could not initialize the library.\n");
//        return -2;
//    }
//    else
//    {
//        mlfMcc_fuse_particles_3d(
//            4,
//            &transformed_coordinates_x,
//            &transformed_coordinates_y,
//            &transformed_coordinates_z,
//            &transformation_parameters,
//            mx_n_particles,
//            mx_n_localizations_per_particle,
//            mx_coordinates_x,
//            mx_coordinates_y,
//            mx_coordinates_z,
//            mx_weights_xy,
//            mx_weights_z,
//            mx_channel_ids,
//            mx_averaging_channel_id,
//            mx_n_iterations_all2all,
//            mx_n_iterations_one2all,
//            mx_symmetry_order);
//
//        double * tcx = mxGetPr(transformed_coordinates_x);
//        double * tcy = mxGetPr(transformed_coordinates_y);
//        double * tcz = mxGetPr(transformed_coordinates_z);
//        double * tp = mxGetPr(transformation_parameters);
//
//        mcc_fuse_particles_3dTerminate();
//        mxDestroyArray(transformed_coordinates_x);
//        mxDestroyArray(transformed_coordinates_y);
//        mxDestroyArray(transformed_coordinates_z);
//        mxDestroyArray(transformation_parameters);
//
//        mxDestroyArray(mx_n_particles);
//        mxDestroyArray(mx_n_localizations_per_particle);
//        mxDestroyArray(mx_coordinates_x);
//        mxDestroyArray(mx_coordinates_y);
//        mxDestroyArray(mx_coordinates_z);
//        mxDestroyArray(mx_weights_xy);
//        mxDestroyArray(mx_weights_z);
//        mxDestroyArray(mx_channel_ids);
//        mxDestroyArray(mx_averaging_channel_id);
//        mxDestroyArray(mx_n_iterations_all2all);
//        mxDestroyArray(mx_n_iterations_one2all);
//        mxDestroyArray(mx_symmetry_order);
//    }
//
//    mclTerminateApplication();
//    return 0;
//}

//int main(int argc, char const *argv[])
//{
//    if (!mclInitializeApplication(NULL, 0))
//    {
//        fprintf(stderr, "Could not initialize the application.\n");
//        return -1;
//    }
//    return mclRunMain((mclMainFcnType)example_fuse_particles_3d, argc, argv);
//
//    std::cout << std::endl << "Example completed!" << std::endl;
//    std::cout << "Press ENTER to exit" << std::endl;
//    std::getchar();
//
//    return 0;
//}

int main(int argc, char const *argv[])
{
    // input
    int const n_particles = 2;
    std::vector<int> n_localizations_per_particle = N_LOCALIZATIONS_PER_PARTICLE;
    std::vector<double> coordinates_x = COORDINATES_X;
    std::vector<double> coordinates_y = COORDINATES_Y;
    std::vector<double> coordinates_z = COORDINATES_Z;
    std::vector<double> weights_xy = WEIGHTS_XY;
    std::vector<double> weights_z = WEIGHTS_Z;
    std::vector<int> channel_ids = CHANNEL_IDS;
    int averaging_channel_id = 0;
    int n_iterations_alltoall = 1;
    int n_iterations_onetoall = 2;
    int symmetry_order = 0;

    std::size_t const n_localizations = n_localizations_per_particle[0] + n_localizations_per_particle[1];

    // output
    double * transformed_coordinates_x = (double *)malloc(n_localizations * sizeof(double));
    double * transformed_coordinates_y = (double *)malloc(n_localizations * sizeof(double));
    double * transformed_coordinates_z = (double *)malloc(n_localizations * sizeof(double));
    double * transformation_parameters = (double *)malloc(12 * sizeof(double));

    // run
    fuse_particles_3d(
        transformed_coordinates_x,
        transformed_coordinates_y,
        transformed_coordinates_z,
        transformation_parameters,
        n_particles,
        n_localizations_per_particle.data(),
        coordinates_x.data(),
        coordinates_y.data(),
        coordinates_z.data(),
        weights_xy.data(),
        weights_z.data(),
        channel_ids.data(),
        averaging_channel_id,
        n_iterations_alltoall,
        n_iterations_onetoall,
        symmetry_order);

    std::cout << std::endl << "Example completed!" << std::endl;
    std::cout << "Press ENTER to exit" << std::endl;
    std::getchar();

    return 0;
}