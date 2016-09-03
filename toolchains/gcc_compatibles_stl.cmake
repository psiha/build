################################################################################
#
# T:N.U.N. STL options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" )
    set( USING_CLANG true )
    set( TNUN_CPP_LIBRARY_DEFAULT "libc++" )
else()
    set( USING_GCC true )
    set( TNUN_CPP_LIBRARY_DEFAULT "stdc++" )
endif()

set( TNUN_CPP_LIBRARY ${TNUN_CPP_LIBRARY_DEFAULT} CACHE STRING "C++ library used" )
set_property( CACHE TNUN_CPP_LIBRARY PROPERTY STRINGS "libc++" "stdc++" )

if(${USING_CLANG})
    if( ${TNUN_CPP_LIBRARY} STREQUAL "libc++" )
        add_compile_options( -stdlib=libc++ )
        link_libraries( -stdlib=libc++ )
    else()
        add_compile_options( -stdlib=libstdc++ )
        link_libraries( -stdlib=libstdc++ )
    endif()
endif()

if( ${USING_GCC} )
    if( ${TNUN_CPP_LIBRARY} STREQUAL "libc++" )
        add_compile_options( -nostdinc++ -I${TNUN_LIBCPP_LOCATION} )
        link_libraries( -lc++ -lc++abi -lm -lc -lgcc )
    endif()
endif()
