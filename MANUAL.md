# 3Dalltoall

## Build instructions

Requires CMake

### Windows

### Linux
echo "************ Go to source directory ************"
cd ~/Sources/GitHub

echo "************ Clone repository ************"
git clone https://github.com/berndrieger/3Dalltoall.git --recursive

echo "************ Go to build directory ************"
cd ~/Build/3Dalltoall

echo "************ Configure CMake ************"
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_COMPILER=gcc-5 -DCUB_ROOT_DIR=~/Sources/cub-1.8.0 ~/Sources/GitHub/3Dalltoall/

echo "************ Build ************"
make

echo "************ Set linker search paths ************"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/R2017b/runtime/glnxa64:/usr/local/MATLAB/R2017b/bin/glnxa64:/usr/local/MATLAB/R2017b/sys/os/glnxa64:/usr/local/MATLAB/R2017b/sys/opengl/lib/glnxa64:/home/aprzyby/Build/3Dalltoall/c_interface
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6

echo "************ Go to example directory ************"
cd ~/Build/3Dalltoall/c_interface/examples

echo "************ Execute example ************"
./example_fuse_particles_3d


### Matlab interface

### C interface

Does not require Matlab.

### Python interface

Does not require Matlab. Is based on the C interface. Requires NumPy.

[//]: # (See also https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
