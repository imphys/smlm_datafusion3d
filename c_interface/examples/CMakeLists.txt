

# example
add_executable( example_fuse_particles_3d example_fuse_particles_3d.cpp data.h )

target_link_libraries(example_fuse_particles_3d ${mcc_build_directory}/fuse_particles_3d.lib ${Matlab_RT_LIBRARY})

target_include_directories(example_fuse_particles_3d PRIVATE
    ${Matlab_INCLUDE_DIRS}
    ${mcc_build_directory})

set_property( TARGET example_fuse_particles_3d
    PROPERTY RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}" )
    
set_property( TARGET example_fuse_particles_3d PROPERTY FOLDER examples )

add_dependencies(example_fuse_particles_3d mcc_fuse_particles_3d)