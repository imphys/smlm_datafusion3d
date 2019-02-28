
### CMake ###

cmake_minimum_required(VERSION 3.11)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

project(alltoall3d)

### Missing paths

set(CUB_ROOT_DIR "!SET PATH!" CACHE PATH "Path to CUB library")
if(CUB_ROOT_DIR STREQUAL "!SET PATH!" OR CUB_ROOT_DIR STREQUAL "")
    message(SEND_ERROR "set CUB_ROOT_DIR (to CUB library path)")
    return()
endif()

### CUDA ###

find_package(CUDA 6.5 REQUIRED)

set( DEFAULT_CUDA_ARCH All )

set( CUDA_ARCHITECTURES ${DEFAULT_CUDA_ARCH} CACHE STRING
  "Auto | Common | All | ... see CUDA_SELECT_NVCC_ARCH_FLAGS(...)" )

if( CUDA_ARCHITECTURES STREQUAL Auto )
  set( file ${PROJECT_BINARY_DIR}/detect_cuda_architectures.cpp )
  file( WRITE ${file} ""
    "#include <cuda_runtime.h>\n"
    "#include <cstdio>\n"
    "int main()\n"
    "{\n"
    "  int count = 0;\n"
    "  if (cudaSuccess != cudaGetDeviceCount(&count)) return -1;\n"
    "  if (count == 0) return -1;\n"
    "  for (int device = 0; device < count; ++device)\n"
    "  {\n"
    "    cudaDeviceProp prop;\n"
    "    if (cudaSuccess == cudaGetDeviceProperties(&prop, device))\n"
    "      std::printf(\"%d.%d \", prop.major, prop.minor);\n"
    "  }\n"
    "  return 0;\n"
    "}\n"
  )
  try_run( run_result compile_result ${PROJECT_BINARY_DIR} ${file}
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${CUDA_INCLUDE_DIRS}"
    LINK_LIBRARIES ${CUDA_LIBRARIES}
    RUN_OUTPUT_VARIABLE architectures
  )
  if( run_result EQUAL 0 )
    string( REPLACE "2.1" "2.1(2.0)" architectures "${architectures}" )
    if( CUDA_VERSION VERSION_LESS "7.0" )
      string( REGEX REPLACE "3\\.[27]|5\\.[23]|6\\.[01]" "5.2+PTX" architectures "${architectures}" )
    elseif( CUDA_VERSION VERSION_LESS "8.0" )
      string( REGEX REPLACE "5\\.3|6\\.[01]" "5.3+PTX" architectures "${architectures}" )
    endif()
    set( CUDA_ARCHITECTURES "${architectures}" )
  endif()
elseif( CUDA_ARCHITECTURES STREQUAL All )
# All does not include the latest PTX!
  set( CUDA_ARCHITECTURES "3.0" "3.5" "5.0" "5.2" )
  if( CUDA_VERSION VERSION_LESS "9.0" )
    list( INSERT CUDA_ARCHITECTURES 0 "2.1(2.0)" )
  endif()
  if( CUDA_VERSION VERSION_GREATER "6.5" )
    list( APPEND CUDA_ARCHITECTURES "3.2" "3.7" "5.3" )
  endif()
  if( CUDA_VERSION VERSION_GREATER "7.5" )
    list( APPEND CUDA_ARCHITECTURES "6.0" "6.1" )
  endif()
  if( CUDA_VERSION VERSION_GREATER "8.0" )
    list( APPEND CUDA_ARCHITECTURES "6.2" "7.0" )
  endif()
  string( APPEND CUDA_ARCHITECTURES "+PTX" )
endif()
message( STATUS "CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}" )
CUDA_SELECT_NVCC_ARCH_FLAGS( code_generation_flags "${CUDA_ARCHITECTURES}" )
list( APPEND CUDA_NVCC_FLAGS ${code_generation_flags} )
message( STATUS "CUDA_NVCC_FLAGS=${code_generation_flags}" )

### MATLAB ###

find_package(Matlab COMPONENTS MX_LIBRARY)

set( matlab_package_build_directory "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/mex" )

### Subdirectories ###
add_subdirectory(expdist)
add_subdirectory(gausstransform)
