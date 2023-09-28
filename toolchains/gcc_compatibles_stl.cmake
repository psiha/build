################################################################################
#
# T:N.U.N. STL options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" )
    set( CLANG true )
    set( TNUN_CPP_LIBRARY_DEFAULT "libc++" )
else()
    set( GCC true )
    set( TNUN_CPP_LIBRARY_DEFAULT "stdc++" )
endif()

set( TNUN_CPP_LIBRARY ${TNUN_CPP_LIBRARY_DEFAULT} CACHE STRING "C++ library used" )
set_property( CACHE TNUN_CPP_LIBRARY PROPERTY STRINGS "libc++" "stdc++" )

if( CLANG AND NOT EMSCRIPTEN )
    if( ${TNUN_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND TNUN_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++> )
        list( APPEND TNUN_common_link_options -stdlib=libc++ )
    else()
        list( APPEND TNUN_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libstdc++> )
        list( APPEND TNUN_common_link_options -stdlib=libstdc++ )
    endif()
endif()

if( GCC )
    if( ${TNUN_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND TNUN_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-nostdinc++ -I${TNUN_LIBCPP_LOCATION}> )
        list( APPEND TNUN_common_link_options -lc++ -lc++abi -lm -lc -lgcc )
    endif()
endif()
