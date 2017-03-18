################################################################################
#
# T:N.U.N. build options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

# https://cmake.org/Bug/view.php?id=15939
# http://stackoverflow.com/questions/31355692/cmake-support-for-gccs-link-time-optimization-lto
set( CMAKE_INTERPROCEDURAL_OPTIMIZATION true )
set( CMAKE_VISIBILITY_INLINES_HIDDEN    true )

set( TNUN_compiler_debug_symbols       -g                                    )
set( TNUN_compiler_debug_flags         -O0 -DDEBUG -D_DEBUG                  )
set( TNUN_compiler_LTO                 -flto                                 )
set( TNUN_linker_LTO                   -flto                                 )
set( TNUN_compiler_fastmath            -ffast-math -ffp-contract=fast        )
set( TNUN_compiler_rtti_on             -frtti                                )
set( TNUN_compiler_rtti_off            -fno-rtti                             )
set( TNUN_compiler_exceptions_on       -fexceptions                          )
set( TNUN_compiler_exceptions_off      -fno-exceptions                       )
set( TNUN_compiler_optimize_for_speed  -O3                                   )
set( TNUN_compiler_optimize_for_size   -Os                                   )
set( TNUN_compiler_report_optimization -ftree-vectorizer-verbose=6           )
set( TNUN_compiler_release_flags       -fomit-frame-pointer -ffunction-sections -fmerge-all-constants -fno-stack-protector )
set( TNUN_default_warnings             -Wall -Wextra -Wstrict-aliasing       )
set( TNUN_warnings_as_errors           -Werror                               )
set( TNUN_native_optimization          -march=native -mtune=native           )

add_compile_options( -fstrict-aliasing $<$<COMPILE_LANGUAGE:CXX>:-fstrict-enums> -fvisibility=hidden $<$<COMPILE_LANGUAGE:CXX>:-fvisibility-inlines-hidden> -fPIC )

# "Unknown language" error with CMake 3.5.2 if COMPILE_LANGUAGE:C is used.
# + 'COMPILE_LANGUAGE' isn't supported by VS generators:
# https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#logical-expressions

## Implementation note:
# set( CMAKE_CXX_STANDARD 14 ) appends '-std=gnu++14' option on all targets after all compile flags have been processed.
# This means that '-std=gnu++14' is given to compiler *after* '-std=gnu++1z', which basically disables C++1z support.
# Correct way of enabling C++1z would be by uncommenting line below and commenting out line 'set( CMAKE_CXX_STANDARD 14 )'.
# However, such decision can cause problems with some 3rd party libraries (Qt for instance) which have their own CMake 
# packages which enfore usage of this variable.
#                                                     ( 04.09.2016. Nenad Miksa )

# add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++1z> )
# add_compile_options( $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:-std=gnu11> )


set( CMAKE_C_STANDARD   11 )
set( CMAKE_CXX_STANDARD 14 )

# https://cmake.org/cmake/help/v3.3/policy/CMP0063.html
cmake_policy( SET CMP0063 NEW )
