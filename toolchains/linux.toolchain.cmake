################################################################################
#
# T:N.U.N. Linux CMake tool chain file.
#
# Copyright (c) 2016 - 2017. Domagoj Saric.
#
################################################################################

# MACOSX_RPATH

set( CPACK_SYSTEM_NAME "Linux" )

set( LINUX true )

set( TNUN_os_suffix Linux )

if( NOT DEFINED TNUN_ABI )
    if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
        if ( ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64" )
            set( TNUN_ABI_DEFAULT aarch64 )
        else()
            set( TNUN_ABI_DEFAULT x64 )
        endif()
    else()
        set( TNUN_ABI_DEFAULT x86 )
    endif()

    set( TNUN_ABI ${TNUN_ABI_DEFAULT} CACHE STRING "Build architecture / ABI" )
    set_property( CACHE TNUN_ABI PROPERTY STRINGS "x64" "x86" "aarch64" )

endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc.cmake" )
endif()

set( TNUN_LIBCPP_LOCATION /usr/include/c++/v1 )
include( ${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles_stl.cmake )

option( TNUN_STATIC_LIBC "Link all binaries statically with libc and libc++" false )

if( ${TNUN_STATIC_LIBC} )
    list( APPEND TNUN_common_link_options -static )
    if( ${TNUN_CPP_LIBRARY} STREQUAL "stdc++" )
        list( APPEND TNUN_common_link_options -static-libstdc++ -static-libgcc )
    elseif( ${TNUN_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND TNUN_common_link_options -s c++ pthread dl c++abi unwind c dl m )
    endif()
endif()

set( TNUN_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/linux" )
include( "${TNUN_arch_include_dir}/${TNUN_ABI}.abi.cmake" )

list( APPEND TNUN_common_link_options $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )

set( TNUN_USE_LINKER "default" CACHE STRING "Linker to use" )
set_property( CACHE TNUN_USE_LINKER PROPERTY STRINGS "default" "gold" "lld" )

if ( NOT TNUN_USE_LINKER STREQUAL "default" )
    list( APPEND TNUN_common_link_options -fuse-ld=${TNUN_USE_LINKER} )

    if ( TNUN_USE_LINKER STREQUAL "gold" AND CLANG )
        set( TNUN_linker_LTO ${TNUN_linker_LTO_gold} )
    endif()
endif()

################################################################################
# malloc overcommit policy
# Linux has a 'configurable' overcommit policy.
# https://www.etalabs.net/overcommit.html
# https://news.ycombinator.com/item?id=2544387
# http://elinux.org/images/a/a3/CELF_AvoidOOM.pdf
################################################################################

set( TNUN_MALLOC_OVERCOMMIT_POLICY Partial )


################################################################################
# TNUN_setup_target_for_arch()
################################################################################

function( TNUN_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${TNUN_os_suffix}" )
endfunction()
