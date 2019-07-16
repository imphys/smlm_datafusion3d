"""
    Example for the Python binding of the 3Dalltoall library.
    https://github.com/berndrieger/3Dalltoall

    Equivalent to example_fuse_particles_3d.cpp in the C interface part.
"""

import py3Dalltoall.fuse_particles as fp
import example_data as d

if __name__ == '__main__':

    # call fuse particles
    transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters = fp.fuse_particles_3d(
        d.localizations_per_particle, d.coordinates_x, d.coordinates_y, d.coordinates_z, d.weights_xy, d.weights_z, d.channel_ids,
        number_iterations_one2all=2, symmetry_order=8)