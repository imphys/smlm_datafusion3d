
# return if matlab not found
if (NOT Matlab_FOUND)
    message("No  suitable MATLAB and/or MX_LIBRARY version found - skipping MATLAB binding!")
    return()
endif()

add_library(mex_expdist SHARED mex_expdist.cpp)
add_library(mex_expdist_cpu SHARED mex_expdist_cpu.cpp)

set_target_properties(mex_expdist
  PROPERTIES
    PREFIX ""
    SUFFIX .${Matlab_MEX_EXTENSION}
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}"
)
set_target_properties(mex_expdist_cpu
  PROPERTIES
    PREFIX ""
    SUFFIX .${Matlab_MEX_EXTENSION}
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}"
)

# include directories
target_include_directories(mex_expdist PRIVATE ${Matlab_INCLUDE_DIRS} ${Matlab_SOURCE_DIR} ../)
target_include_directories(mex_expdist_cpu PRIVATE ${Matlab_INCLUDE_DIRS} ${Matlab_SOURCE_DIR} ../)

# link libraries
target_link_libraries(mex_expdist expdist ${Matlab_LIBRARIES})
target_link_libraries(mex_expdist_cpu expdist ${Matlab_LIBRARIES})

# export mexFunction
if(WIN32)
  SET(CMAKE_SHARED_LINKER_FLAGS "/export:mexFunction")
endif()

# MATLAB package

set( binary_mex $<TARGET_FILE:mex_expdist> $<TARGET_FILE:mex_expdist_cpu> )

set( binary_lib $<TARGET_FILE:expdist> )

add_custom_target( MATLAB_expdist_PACKAGE ALL
  COMMAND ${CMAKE_COMMAND} -E
    make_directory ${matlab_package_build_directory}
  COMMAND ${CMAKE_COMMAND} -E
    copy_if_different ${binary_mex} ${matlab_package_build_directory}
  COMMAND ${CMAKE_COMMAND} -E
    copy_if_different ${binary_lib} ${matlab_package_build_directory}
  COMMAND ${CMAKE_COMMAND} -E
    remove ${binary_mex}
  COMMENT "Creating expdist Matlab package"
)
