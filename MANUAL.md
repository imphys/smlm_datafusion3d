# 3Dalltoall

This code is created for a Windows or Linux environment. The main code is written in MATLAB and some of the compute-intensive kernels have been written in CUDA and C++. The Matlab code gets compiled into a library using
the [Matlab compiler](https://www.mathworks.com/products/compiler.html), which can be passed to anyone without
the need to acquire a Matlab license. The compiled Matlab code is accessed from a C interface, which is used
by the included Python package.

## Requirements

The build framework requires CMake.
If the GPU shall be used, a CUDA compiler and libraries and the [CUB library](https://nvlabs.github.io/cub/).
For the Matlab compilation, Matlab must be installed.
For the Python packaging, Python must be installed.

## Build instructions

### Get the sources

The Git repository uses submodules. Include them in a _git clone_ action using the _--recursive_ option.

> git clone https://github.com/berndrieger/3Dalltoall.git --recursive

In the following

- BUILD_DIRECTORY is the directory where the project will be built
- SOURCE_DIRECTORY is the root directory of the sources
- CUB_DIRECTORY is the root directory of the downloaded [CUB library](https://nvlabs.github.io/cub/) sources

### Windows

Either use the CMake GUI or use CMake from the command line. On the command line and for Visual Studio 2015,
use the following command.

> cd BUILD_DIRECTORY<br>
> cmake -G "Visual Studio 14 2015 Win 64" -DCUB_ROOT_DIR=CUB_DIRECTORY SOURCE_DIRECTORY

Test the example by running the example_fuse_particles_3d target. Test the Python binding by installing the created wheel in a Python environment
and executing an example script.

> pip install BUILD_DIRECTORY/py3Dalltoall/dist/py3Dalltoall-1.0.0-py2.py3-none-any.whl<br>
> cd SOURCE_DIRECTORY/python/examples<br>
> python three_particles.py

> pip install BUILD_DIRECTORY/py3Dalltoall/dist/py3Dalltoall-1.0.0-py2.py3-none-any.whl<br>

### Linux

Either use the CMake GUI or use CMake from the command line. On the command line, use the following command.

> cd BUILD_DIRECTORY<br>
> cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_COMPILER=gcc-5 -DCUB_ROOT_DIR=CUB_DIRECTORY SOURCE_DIRECTORY

Then build the project

> make

To use the mex files in Matlab and to use the C interface library the library paths have to be adapted

> export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/R2017b/runtime/glnxa64:/usr/local/MATLAB/R2017b/bin/glnxa64:/usr/local/MATLAB/R2017b/sys/os/glnxa64:/usr/local/MATLAB/R2017b/sys/opengl/lib/glnxa64:BUILD_DIRECTORY/c_interface<br>
> export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6

Test the build by running the example.

> cd BUILD_DIRECTORY/c_interface/examples<br>
> ./example_fuse_particles_3d

Test the Python binding

> virtualenv test<br>
> source test/bin/activate<br>
> pip install numpy<br>
> pip install BUILD_DIRECTORY/py3Dalltoall/dist/py3Dalltoall-1.0.0-py2.py3-none-any.whl<br>
> cd SOURCE_DIRECTORY/python/examples<br>
> python three_particles.py


### Matlab interface

The Matlab interface of the project is the _fuse_particles_3d.m_ Matlab script located in the Matlab folder.

> function [transformed_coordinates_x, transformed_coordinates_y, transformed_coordinates_z, transformation_parameters]
    = fuse_particles_3d(n_particles, n_localizations_per_particle, coordinates_x, coordinates_y,
        coordinates_z, weights_xy, weights_z, channel_ids, averaging_channel_id, n_iterations_all2all,
        n_iterations_one2all, symmetry_order, outlier_threshold)


### C interface

Using the C interface does not require Matlab to be installed, however a [Matlab Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html)
must be installed.

> int fuse_particles_3d(
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
        int symmetry_order,
        double outlier_threshold);

#### Python binding to the C interface 

Using the Python binding additionally requires [NumPy](https://www.numpy.org/). During the building a Python
wheel with the _py3Dalltoall_ module is created and can be installed using pip.

> def fuse_particles_3d(localizations_per_particle, coordinates_x, coordinates_y, coordinates_z, weights_xy, weights_z,
                      channel_ids=None, averaging_channel_id=0, number_iterations_all2all=1, number_iterations_one2all=10,
                      symmetry_order=0, outlier_threshold=1):

[//]: # (See also https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
