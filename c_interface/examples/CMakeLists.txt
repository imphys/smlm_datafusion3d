
# example
add_executable( example_fuse_particles_3d example_fuse_particles_3d.cpp data.h )

target_include_directories(example_fuse_particles_3d PRIVATE ${CMAKE_SOURCE_DIR}/c_interface)
    
if(WIN32)
    set_property( TARGET example_fuse_particles_3d
        PROPERTY RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/example" )
    target_link_libraries(example_fuse_particles_3d fuse_particles_3d ${Matlab_RT_LIBRARY} delayimp.lib)
    target_link_options(example_fuse_particles_3d PRIVATE /delayload:fuse_particles_3d.dll)
else()
    target_link_libraries(example_fuse_particles_3d fuse_particles_3d)
endif()

set_property( TARGET example_fuse_particles_3d PROPERTY FOLDER examples )
add_dependencies(example_fuse_particles_3d fuse_particles_3d)
