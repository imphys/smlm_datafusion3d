if(CMAKE_CUDA_COMPILER)
    set(sources
        expdist.cu
        expdist_functions.cuh
        expdist_ref.cu
        matrix_functions.cuh
        expdist.h
        expdist_ref.h
    )

    # For CUDA < 11, include the external CUB path
    if(CMAKE_CUDA_COMPILER_VERSION VERSION_LESS "11.0")
        list(APPEND sources ${CUB_ROOT_DIR}/cub/cub.cuh)
        target_include_directories(expdist PRIVATE ${CUB_ROOT_DIR})
    endif()

    # Create a shared CUDA library
    add_library(expdist SHARED ${sources})

    # Set the output directory and CUDA architectures
    set_target_properties(expdist PROPERTIES 
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}"
        CUDA_ARCHITECTURES "${CUDA_ARCHITECTURES}"
    )

    # Add optional CUDA flags
    target_compile_options(expdist PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:--generate-line-info>)
else()
    message(SEND_ERROR "CUDA is not enabled or configured!")
endif()

# Add the "mex" subdirectory
add_subdirectory(mex)
