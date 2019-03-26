
# mcc_fuse_particles_3d
set(mcc_build_directory "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}")

if(WIN32)
    add_custom_target( mcc_fuse_particles_3d ALL
        COMMAND
            copy /Y \"${CMAKE_SOURCE_DIR}/MATLAB\\fuse_particles_3d.m\" \"${mcc_build_directory}/mcc_fuse_particles_3d.m\" >NUL
        COMMAND
            mcc -l -a ${CMAKE_SOURCE_DIR}/MATLAB -a ${matlab_package_build_directory} -d ${mcc_build_directory} ${mcc_build_directory}/mcc_fuse_particles_3d.m
        COMMAND
        COMMENT "Creating fuse_particles_3d library")
else()
    add_custom_target( mcc_fuse_particles_3d ALL
        COMMAND
            cp ${CMAKE_SOURCE_DIR}/MATLAB/fuse_particles_3d.m ${mcc_build_directory}/mcc_fuse_particles_3d.m
        COMMAND
            mcc -l -a ${CMAKE_SOURCE_DIR}/MATLAB -a ${matlab_package_build_directory} -d ${mcc_build_directory} ${mcc_build_directory}/mcc_fuse_particles_3d.m
        COMMAND
        COMMENT "Creating fuse_particles_3d library")
endif()

add_dependencies(mcc_fuse_particles_3d
    expdist
    gausstransform
    MATLAB_gausstransform_PACKAGE
    MATLAB_expdist_PACKAGE
    mexFigtree
    copy_figtree)

add_library(link_to_mcc_fuse_particles_3d STATIC IMPORTED)

set_property(TARGET link_to_mcc_fuse_particles_3d PROPERTY IMPORTED_LOCATION
    ${mcc_build_directory}/mcc_fuse_particles_3d.${lib_file_extension})

# fuse_particles_3d
add_library(fuse_particles_3d SHARED fuse_particles_3d.cpp fuse_particles_3d.h fuse_particles_3d.def)

set_property( TARGET fuse_particles_3d PROPERTY RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}" )

target_link_libraries(fuse_particles_3d link_to_mcc_fuse_particles_3d ${Matlab_RT_LIBRARY})

target_include_directories(fuse_particles_3d PRIVATE ${Matlab_INCLUDE_DIRS} ${mcc_build_directory})

add_dependencies(fuse_particles_3d mcc_fuse_particles_3d)

# examples
add_subdirectory(examples)
