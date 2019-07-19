#include <iostream>
#include <string>
#include <vector>
#include "fuse_particles_3d.h"
#include "data.h"

#ifdef _WIN32
#include <Windows.h>
#define LOAD_LIBRARY(PATH) LoadLibrary(PATH)
#else
#define LOAD_LIBRARY(PATH) 
#endif

#define PI 3.1415926535897932384626433832795

int main(int argc, char const *argv[])
{
    HMODULE lib;
    try
    {
        if (!(lib = LOAD_LIBRARY("../../fuse_particles_3d.dll")))
            throw -1;
    }
    catch(int err)
    {        
        std::cout << std::endl << "    !!! Failed to load fuse_particles_3d.dll !!!" << std::endl << std::endl;

        return err;
    }

    // input
    int32_t const n_particles = N_PARTICLES;
    std::vector<int32_t> n_localizations_per_particle = N_LOCALIZATIONS_PER_PARTICLE;
    std::vector<double> coordinates_x = COORDINATES_X;
    std::vector<double> coordinates_y = COORDINATES_Y;
    std::vector<double> coordinates_z = COORDINATES_Z;
    std::vector<double> precision_xy = PRECISION_XY;
    std::vector<double> precision_z = PRECISION_Z;
    double const gauss_transform_scale = 0.1;
    std::vector<int32_t> channel_ids = CHANNEL_IDS;
    int32_t averaging_channel_id = 0;
    int32_t symmetry_order = 0;
    double transformation_refinement_threshold = PI;
    int32_t use_gpu = 0;

    std::size_t n_localizations = 0;
    for (int i = 0; i < n_particles; i++)
        n_localizations += n_localizations_per_particle[i];

    // input/output
    std::vector<double> registration_matrix((n_particles * (n_particles - 1)) / 2 * 7);

    // output
    std::vector<double> transformed_coordinates_x(n_localizations);
    std::vector<double> transformed_coordinates_y(n_localizations);
    std::vector<double> transformed_coordinates_z(n_localizations);
    std::vector<double> transformation_parameters(n_particles * 16);

    // run
    fuse_particles_3d_alltoall(
        registration_matrix.data(),
        n_particles,
        n_localizations_per_particle.data(),
        coordinates_x.data(),
        coordinates_y.data(),
        coordinates_z.data(),
        precision_xy.data(),
        precision_z.data(),
        gauss_transform_scale,
        channel_ids.data(),
        averaging_channel_id, 
        use_gpu);

    fuse_particles_3d_refinement(
        transformed_coordinates_x.data(),
        transformed_coordinates_y.data(),
        transformed_coordinates_z.data(),
        transformation_parameters.data(),
        n_particles,
        n_localizations_per_particle.data(),
        registration_matrix.data(),
        coordinates_x.data(),
        coordinates_y.data(),
        coordinates_z.data(),
        transformation_refinement_threshold);

    fuse_particles_3d_onetoall(
        transformed_coordinates_x.data(),
        transformed_coordinates_y.data(),
        transformed_coordinates_z.data(),
        transformation_parameters.data(),
        n_particles,
        n_localizations_per_particle.data(),
        transformed_coordinates_x.data(),
        transformed_coordinates_y.data(),
        transformed_coordinates_z.data(),
        transformation_parameters.data(),
        precision_xy.data(),
        precision_z.data(),
        gauss_transform_scale,
        channel_ids.data(),
        averaging_channel_id,
        symmetry_order, 
        use_gpu);

    std::cout << std::endl << "Example completed!" << std::endl;
    std::cout << "Press ENTER to exit" << std::endl;
    std::getchar();

    return 0;
}
