################################################################################
#
# PSI STL options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Nenad Miksa. All rights reserved.
#
################################################################################

if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" )
    set( CLANG true )
    set( PSI_CPP_LIBRARY_DEFAULT "libc++" )
else()
    set( GCC true )
    set( PSI_CPP_LIBRARY_DEFAULT "stdc++" )
endif()

set( PSI_CPP_LIBRARY ${PSI_CPP_LIBRARY_DEFAULT} CACHE STRING "C++ library used" )
set_property( CACHE PSI_CPP_LIBRARY PROPERTY STRINGS "libc++" "stdc++" )

if( CLANG AND NOT EMSCRIPTEN )
    if( ${PSI_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++> )
        list( APPEND PSI_common_link_options -stdlib=libc++ )
        # https://libcxx.llvm.org/Hardening.html
        list( APPEND PSI_compiler_debug_flags
            -D_LIBCPP_DEBUG=2
            -D_LIBCPP_ENABLE_ASSERTIONS=1
            -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG # TODO make this level configurable
            -D_LIBCPP_ABI_BOUNDED_ITERATORS
            -D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STRING
            -D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_VECTOR
            -D_LIBCPP_ABI_BOUNDED_UNIQUE_PTR
            -D_LIBCPP_ABI_BOUNDED_ITERATORS_IN_STD_ARRAY
        )
    else()
        list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libstdc++> )
        list( APPEND PSI_common_link_options -stdlib=libstdc++ )
    endif()
endif()

if( GCC )
    if( ${PSI_CPP_LIBRARY} STREQUAL "libc++" )
        list( APPEND PSI_common_compiler_options $<$<COMPILE_LANGUAGE:CXX>:-nostdinc++ -I${PSI_LIBCPP_LOCATION}> )
        list( APPEND PSI_common_link_options -lc++ -lc++abi -lm -lc -lgcc )
    endif()
endif()
