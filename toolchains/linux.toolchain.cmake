################################################################################
#
# T:N.U.N. Apple OS X CMake tool chain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

# MACOSX_RPATH

set( CPACK_SYSTEM_NAME "Linux" )

set( LINUX true )

set( TNUN_os_suffix Linux )

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc.cmake" )
endif()

option( TNUN_STATIC_LIBC "Link all binaries statically with libc and libc++" false )
if( ${TNUN_STATIC_LIBC} )
    add_compile_options( -static )
    link_libraries( -static-libstdc++ -static-libgcc )
endif()

add_definitions(
    -D__STDC_FORMAT_MACROS
    -D_GLIBCXX_USE_CXX11_ABI=0
)

if( NOT DEFINED TNUN_ABI )
    if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
        set( TNUN_ABI_DEFAULT x64 )
    else()
        set( TNUN_ABI_DEFAULT x86 )
    endif()

    set(TNUN_ABI ${TNUN_ABI_DEFAULT} CACHE STRING "Build architecture / ABI")
    set_property(CACHE TNUN_ABI PROPERTY STRINGS "x64" "x86")

endif()

set( TNUN_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/linux" )
include( "${TNUN_arch_include_dir}/${TNUN_ABI}.abi.cmake" )

################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_os_suffix}" )
endfunction()
