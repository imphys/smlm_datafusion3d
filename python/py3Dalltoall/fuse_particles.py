"""
    Python binding for 3Dalltoall.
    See https://github.com/berndrieger/3Dalltoall

    The binding is based on ctypes.
    See https://docs.python.org/3.5/library/ctypes.html, http://www.scipy-lectures.org/advanced/interfacing_with_c/interfacing_with_c.html
"""

import os
from ctypes import cdll, POINTER, c_int, c_double
import numpy as np

# define library loader (actual loading is lazy)
package_dir = os.path.dirname(os.path.realpath(__file__))

if os.name == 'nt':
    lib_path = os.path.join(package_dir, 'fuse_particles_3d.dll') # library name on Windows
elif os.name == 'posix':
    lib_path = os.path.join(package_dir, 'libfuse_particles_3d.so') # library name on Unix
else:
    raise RuntimeError('OS {} not supported by py3Dalltoall.'.format(os.name))

lib = cdll.LoadLibrary(lib_path)

# fuse_particles_3d function in the dll
func = lib.fuse_particles_3d
func.restype = c_int32
func.argtypes = [POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double), c_int32, POINTER(c_int32),
                 POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double),
                 POINTER(c_int32), c_int32, c_int32, c_int32, c_int32, c_double]

def fuse_particles_3d(localizations_per_particle, coordinates_x, coordinates_y, coordinates_z, weights_xy, weights_z,
                      channel_ids=None, averaging_channel_id=0, number_iterations_all2all=1, number_iterations_one2all=10,
                      symmetry_order=0, outlier_threshold=1):
    """

    :return:
    """

    # checks
    number_particles = localizations_per_particle.size
    number_localizations = np.sum(localizations_per_particle)
    d = (number_localizations,)

    if channel_ids is None:
        channel_ids = np.zeros(d, dtype=np.int32)

    if any([not x.flags.c_contiguous for x in [coordinates_x, coordinates_y, coordinates_z, weights_xy, weights_z, channel_ids]]):
        raise RuntimeError('Memory layout of data arrays mismatch')

    # pre-allocate output variables
    transformed_coordinates_x = np.zeros(d, dtype=np.double)
    transformed_coordinates_y = np.zeros(d, dtype=np.double)
    transformed_coordinates_z = np.zeros(d, dtype=np.double)
    transformation_parameters = np.zeros((12*number_particles,), dtype=np.double)

    # call into the library
    status = func(
        transformed_coordinates_x.ctypes.data_as(func.argtypes[0]),
        transformed_coordinates_y.ctypes.data_as(func.argtypes[1]),
        transformed_coordinates_z.ctypes.data_as(func.argtypes[2]),
        transformation_parameters.ctypes.data_as(func.argtypes[3]),
        func.argtypes[4](number_particles),
        localizations_per_particle.ctypes.data_as(func.argtypes[5]),
        coordinates_x.ctypes.data_as(func.argtypes[6]),
        coordinates_y.ctypes.data_as(func.argtypes[7]),
        coordinates_z.ctypes.data_as(func.argtypes[8]),
        weights_xy.ctypes.data_as(func.argtypes[9]),
        weights_z.ctypes.data_as(func.argtypes[10]),
        channel_ids.ctypes.data_as(func.argtypes[11]),
        func.argtypes[12](averaging_channel_id),
        func.argtypes[13](number_iterations_all2all),
        func.argtypes[14](number_iterations_one2all),
        func.argtypes[15](symmetry_order),
        func.argtypes[16](outlier_threshold)
    )

    # check status
    if status != 0:
        raise RuntimeError('status = {}'.format(status))

    # return output values
    return transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters