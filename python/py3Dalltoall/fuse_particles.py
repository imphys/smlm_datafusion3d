"""
    Python binding for 3Dalltoall.
    See https://github.com/berndrieger/3Dalltoall

    The binding is based on ctypes.
    See https://docs.python.org/3.5/library/ctypes.html, http://www.scipy-lectures.org/advanced/interfacing_with_c/interfacing_with_c.html
"""

import os
from ctypes import cdll
import numpy as np

# define library loader (actual loading is lazy)
package_dir = os.path.dirname(os.path.realpath(__file__))

if os.name == 'nt':
	lib_path = os.path.join(package_dir, 'fuse_particles_3d.dll') # library name on Windows
elif os.name == 'posix':
	lib_path = os.path.join(package_dir, 'libfuse_particles_3d.so') # library name on Unix
else:
	raise RuntimeError('OS {} not supported by pyGpufit.'.format(os.name))

lib = cdll.LoadLibrary(lib_path)

def fuse_particles_3d():
    """

    :return:
    """

    # return output values
    return 0