
if (CUDA_FOUND)

    set(sources
        gausstransform.cu
        gausstransform_c.cpp
        gausstransform_ref.h
        kernels.cu
        kernels.cuh
        gausstransform.h
        ${CUB_ROOT_DIR}/cub/cub.cuh)

    #create dll
    cuda_add_library(gausstransform SHARED ${sources})

    target_include_directories(gausstransform PRIVATE ${CUB_ROOT_DIR})

    # set dll output directory
    set_target_properties(gausstransform PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

endif()

add_subdirectory(mex)