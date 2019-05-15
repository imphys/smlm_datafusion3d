
# c_interface

# mcc_fuse_particles_3d
if(WIN32)
    add_custom_target( mcc_fuse_particles_3d ALL
        COMMAND
            copy /Y \"${CMAKE_SOURCE_DIR}/MATLAB\\fuse_particles_3d_onetoall.m\" \"${mcc_build_directory}/mcc_fuse_particles_3d_onetoall.m\" >NUL
        COMMAND
            copy /Y \"${CMAKE_SOURCE_DIR}/MATLAB\\fuse_particles_3d_alltoall.m\" \"${mcc_build_directory}/mcc_fuse_particles_3d_alltoall.m\" >NUL
        COMMAND
            mcc -W lib:mcc_fuse_particles_3d -T link:lib 
            -a ${CMAKE_SOURCE_DIR}/MATLAB -a ${matlab_package_build_directory} -d ${mcc_build_directory} 
            ${mcc_build_directory}/mcc_fuse_particles_3d_onetoall.m ${mcc_build_directory}/mcc_fuse_particles_3d_alltoall.m
        COMMAND
        COMMENT "Creating fuse_particles_3d library")
else()
    add_custom_target( mcc_fuse_particles_3d ALL
        COMMAND
            cp ${CMAKE_SOURCE_DIR}/MATLAB/fuse_particles_3d_onetoall.m ${mcc_build_directory}/mcc_fuse_particles_3d_onetoall.m
        COMMAND
            cp ${CMAKE_SOURCE_DIR}/MATLAB/fuse_particles_3d_alltoall.m ${mcc_build_directory}/mcc_fuse_particles_3d_alltoall.m
        COMMAND
            mcc -W lib:mcc_fuse_particles_3d -T link:lib 
            -a ${CMAKE_SOURCE_DIR}/MATLAB -a ${matlab_package_build_directory} -d ${mcc_build_directory} 
            ${mcc_build_directory}/mcc_fuse_particles_3d_onetoall.m ${mcc_build_directory}/mcc_fuse_particles_3d_alltoall.m
        COMMAND
        COMMENT "Creating fuse_particles_3d library")
endif()

add_dependencies(mcc_fuse_particles_3d
    MATLAB_gausstransform_PACKAGE
    MATLAB_expdist_PACKAGE
    copy_figtree)

add_library(link_to_mcc_fuse_particles_3d STATIC IMPORTED)

set_property(TARGET link_to_mcc_fuse_particles_3d PROPERTY IMPORTED_LOCATION
    ${mcc_build_directory}/mcc_fuse_particles_3d.${static_lib_file_extension})

add_dependencies(link_to_mcc_fuse_particles_3d mcc_fuse_particles_3d)

# fuse_particles_3d
if(WIN32)
    add_library(fuse_particles_3d SHARED
        fuse_particles_3d_alltoall.cpp
        fuse_particles_3d_onetoall.cpp
        fuse_particles_3d.h
        fuse_particles_3d.def
        fuse_particles_3d_initialize.cpp 
        fuse_particles_3d_initialize.h)

    
    target_link_libraries(fuse_particles_3d link_to_mcc_fuse_particles_3d ${Matlab_RT_LIBRARY} delayimp.lib)
    target_link_options(fuse_particles_3d PRIVATE /delayload:mcc_fuse_particles_3d.dll)
else()
    add_library(fuse_particles_3d SHARED
        fuse_particles_3d_alltoall.cpp
        fuse_particles_3d_onetoall.cpp
        fuse_particles_3d.h
        fuse_particles_3d.def)
    
    target_link_libraries(fuse_particles_3d link_to_mcc_fuse_particles_3d ${Matlab_RT_LIBRARY})
endif()

add_dependencies(fuse_particles_3d link_to_mcc_fuse_particles_3d)	
set_property( TARGET fuse_particles_3d PROPERTY RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}" )
target_include_directories(fuse_particles_3d PRIVATE ${Matlab_INCLUDE_DIRS} ${mcc_build_directory})

# examples
add_subdirectory(examples)
