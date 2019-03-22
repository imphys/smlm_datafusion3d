
# mcc_fuse_particles_3d

set( mcc_build_directory "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}" )

add_custom_target( mcc_fuse_particles_3d ALL
  COMMAND
    mcc -l -a ${CMAKE_SOURCE_DIR}/MATLAB -a ${matlab_package_build_directory} -a ${figtree_build_directory} -d ${mcc_build_directory} ${CMAKE_SOURCE_DIR}/MATLAB/fuse_particles_3d.m
  COMMENT "Creating fuse_particles_3d library"
)

add_dependencies(mcc_fuse_particles_3d expdist gausstransform MATLAB_gausstransform_PACKAGE MATLAB_expdist_PACKAGE)

add_library(fuse_particles_3d STATIC IMPORTED)

set_property(TARGET fuse_particles_3d PROPERTY IMPORTED_LOCATION
    ${mcc_build_directory}/fuse_particles_3d.${lib_file_extension})

add_subdirectory(examples)
