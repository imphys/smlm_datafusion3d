
set(sources
    expdist.cu
    expdist_c.cu
    expdist_functions.cuh
    expdist_ref.cu
    kernels.cu
    kernels.cuh
    matrix_functions.cuh
    expdist.h
    expdist_ref.h
    ${CUB_ROOT_DIR}/cub/cub.cuh)

cuda_add_library(expdist SHARED ${sources})

target_include_directories(expdist PRIVATE ${CUB_ROOT_DIR})

# set output directory
set_target_properties(expdist
  PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}"
)

add_subdirectory(mex)
