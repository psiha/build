################################################################################
#
# PSI Linux CMake tool chain file.
#
# Copyright (c) Domagoj Saric.
#
################################################################################

# MACOSX_RPATH

set( CPACK_SYSTEM_NAME "Linux" )

set( LINUX true )

set( PSI_os_suffix Linux )

if( NOT DEFINED PSI_ABI )
    if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 8 )
        if ( ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64" )
            set( PSI_ABI_DEFAULT aarch64 )
        else()
            set( PSI_ABI_DEFAULT x64 )
        endif()
    else()
        set( PSI_ABI_DEFAULT x86 )
    endif()

    set( PSI_ABI ${PSI_ABI_DEFAULT} CACHE STRING "Build architecture / ABI" )
    set_property( CACHE PSI_ABI PROPERTY STRINGS "x64" "x86" "aarch64" )

endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )
else()
    include( "${CMAKE_CURRENT_LIST_DIR}/gcc.cmake" )
endif()

set( PSI_LIBCPP_LOCATION /usr/include/c++/v1 )
include( ${CMAKE_CURRENT_LIST_DIR}/gcc_compatibles_stl.cmake )

option( PSI_STATIC_LIBC "Link all binaries statically with libc and libc++" false )

if( ${PSI_STATIC_LIBC} )
    list( APPEND PSI_common_link_options -static )
    if( ${PSI_CPP_LIBRARY} STREQUAL "stdc++" )
        list( APPEND PSI_common_link_options -static-libstdc++ -static-libgcc )
    elseif( ${PSI_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND PSI_common_link_options -s c++ pthread dl c++abi unwind c dl m )
    endif()
endif()

set( PSI_arch_include_dir "${CMAKE_CURRENT_LIST_DIR}/linux" )
include( "${PSI_arch_include_dir}/${PSI_ABI}.abi.cmake" )

list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )

set( PSI_USE_LINKER "default" CACHE STRING "Linker to use" )
set_property( CACHE PSI_USE_LINKER PROPERTY STRINGS "default" "gold" "lld" )

if ( NOT PSI_USE_LINKER STREQUAL "default" )
    list( APPEND PSI_common_link_options -fuse-ld=${PSI_USE_LINKER} )
    list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-Wl,--icf=all> )

    # https://clang.llvm.org/docs/LTOVisibility.html
    if ( PSI_USE_LINKER STREQUAL "gold" AND CLANG )
        set( PSI_linker_LTO ${PSI_linker_LTO_gold} -plugin-opt=whole-program-visibility )
    elseif ( PSI_USE_LINKER STREQUAL "lld" )
        list( APPEND PSI_linker_LTO -Wl,--lto-whole-program-visibility -Wl,--lto-O3 -Wl,--lto-CGO3 )
        list( APPEND PSI_common_link_options $<$<CONFIG:RELEASE>:-Wl,-O3> )
    endif()
endif()

################################################################################
# malloc overcommit policy
# Linux has a 'configurable' overcommit policy.
# https://www.kernel.org/doc/html/v5.1/vm/overcommit-accounting.html
# https://www.etalabs.net/overcommit.html
# https://news.ycombinator.com/item?id=2544387
# http://elinux.org/images/a/a3/CELF_AvoidOOM.pdf
################################################################################

set( PSI_MALLOC_OVERCOMMIT_POLICY_default Partial )


################################################################################
# PSI_setup_target_for_arch()
################################################################################

function( PSI_setup_target_for_arch target base_target_name arch )
  set_property( TARGET ${target} PROPERTY ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY LIBRARY_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/lib" )
  set_property( TARGET ${target} PROPERTY OUTPUT_NAME                      "${base_target_name}_${PSI_os_suffix}" )
endfunction()
