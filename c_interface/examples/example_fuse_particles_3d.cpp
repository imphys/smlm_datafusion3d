#include <iostream>
#include <vector>
#include "fuse_particles_3d.h"
#include "data.h"

#ifdef _WIN32
    #include <Windows.h>
    #define LOAD_LIBRARY(PATH) LoadLibrary(PATH)
#else
    #define LOAD_LIBRARY(PATH) 
#endif

int main(int argc, char const *argv[])
{
    LOAD_LIBRARY("../../fuse_particles_3d.dll");

    // input
    int32_t const n_particles = N_PARTICLES;
    std::vector<int32_t> n_localizations_per_particle = N_LOCALIZATIONS_PER_PARTICLE;
    std::vector<double> coordinates_x = COORDINATES_X;
    std::vector<double> coordinates_y = COORDINATES_Y;
    std::vector<double> coordinates_z = COORDINATES_Z;
    std::vector<double> weights_xy = WEIGHTS_XY;
    std::vector<double> weights_z = WEIGHTS_Z;
    std::vector<int32_t> channel_ids = CHANNEL_IDS;
    int32_t averaging_channel_id = 0;
    int32_t n_iterations_alltoall = 1;
    int32_t n_iterations_onetoall = 2;
    int32_t symmetry_order = 0;
    double outlier_threshold = 20;

    std::size_t n_localizations = 0;
    for (int i = 0; i < n_particles; i++)
        n_localizations += n_localizations_per_particle[i];

    // output
    double * transformed_coordinates_x = (double *)malloc(n_localizations * sizeof(double));
    double * transformed_coordinates_y = (double *)malloc(n_localizations * sizeof(double));
    double * transformed_coordinates_z = (double *)malloc(n_localizations * sizeof(double));
	double * transformation_parameters = (double *)malloc(n_particles * 12 * sizeof(double));

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
        symmetry_order,
        outlier_threshold);

	free(transformed_coordinates_x);
	free(transformed_coordinates_y);
	free(transformed_coordinates_z);
	free(transformation_parameters);

    std::cout << std::endl << "Example completed!" << std::endl;
    std::cout << "Press ENTER to exit" << std::endl;
    std::getchar();

    return 0;
}
