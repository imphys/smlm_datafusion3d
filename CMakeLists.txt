### CMake ###

cmake_minimum_required(VERSION 3.27) # Updated version
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

project(alltoall3d LANGUAGES CXX CUDA) # Explicitly declare CUDA as a language

### CUDA ###
if(CMAKE_CUDA_COMPILER)
    set(CUDA_ARCHITECTURES "52;60;61;70;75;80;86;90" CACHE STRING
        "Specify CUDA architectures (e.g., 52;60;70)")
    message(STATUS "CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}")

    # Optional: Add CUDA-specific flags
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --generate-line-info")
    message(STATUS "CMAKE_CUDA_FLAGS=${CMAKE_CUDA_FLAGS}")

    # Check for CUDA version and handle CUB
    if(CMAKE_CUDA_COMPILER_VERSION VERSION_LESS "11.0")
        set(CUB_ROOT_DIR "!SET PATH!" CACHE PATH "Path to CUB library for CUDA < 11.0")
        if(CUB_ROOT_DIR STREQUAL "!SET PATH!" OR CUB_ROOT_DIR STREQUAL "")
            message(SEND_ERROR "Set CUB_ROOT_DIR for CUDA versions below 11.0")
            return()
        endif()
        message(STATUS "Using external CUB from ${CUB_ROOT_DIR}")
    else()
        # Set CUB_ROOT_DIR to the bundled CUB directory
        set(CUB_ROOT_DIR "${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}/cub" CACHE PATH "Automatically set CUB path for CUDA >= 11.0")
        message(STATUS "Using CUB bundled with CUDA: ${CUB_ROOT_DIR}")
    endif()
endif()

### File extension for libraries ###
if(WIN32)
    set(shared_lib_file_extension dll)    
    set(static_lib_file_extension lib)
else()
    set(shared_lib_file_extension so)
    set(static_lib_file_extension so)
endif()

### MATLAB ###
find_package(Matlab REQUIRED COMPONENTS MX_LIBRARY MCC_COMPILER)

if(WIN32)
    set(Matlab_RT_LIBRARY "${Matlab_ROOT_DIR}/extern/lib/win64/microsoft/mclmcrrt.lib")
else()
    set(Matlab_RT_LIBRARY "${Matlab_ROOT_DIR}/runtime/glnxa64/libmwmclmcrrt.so")
endif()

set(matlab_package_build_directory "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/mex")
set(figtree_build_directory "${CMAKE_BINARY_DIR}/figtree/${CMAKE_CFG_INTDIR}")

### Subdirectories ###
add_subdirectory(expdist)
add_subdirectory(gausstransform)

### Git Submodules ###
add_subdirectory(figtree)

set(figtree_mex_files $<TARGET_FILE:mexFigtree> $<TARGET_FILE:ann_figtree_version>)
add_custom_target(copy_figtree
    COMMAND ${CMAKE_COMMAND} -E make_directory ${matlab_package_build_directory}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${figtree_mex_files} ${matlab_package_build_directory})
add_dependencies(copy_figtree mexFigtree ann_figtree_version)

set_property(TARGET figtree PROPERTY FOLDER figtree_projects)
set_property(TARGET ann_figtree_version PROPERTY FOLDER figtree_projects)
set_property(TARGET mexFigtree PROPERTY FOLDER figtree_projects)
set_property(TARGET mexFigtreeChooseEvaluationMethod PROPERTY FOLDER figtree_projects)
set_property(TARGET mexFigtreeKCenterClustering PROPERTY FOLDER figtree_projects)
set_property(TARGET run_tests PROPERTY FOLDER figtree_projects)
set_property(TARGET sample PROPERTY FOLDER figtree_projects)
set_property(TARGET copy_figtree PROPERTY FOLDER figtree_projects)
