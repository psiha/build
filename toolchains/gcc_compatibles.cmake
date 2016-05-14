################################################################################
#
# T:N.U.N. build options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_VISIBILITY_INLINES_HIDDEN    true )
set( CMAKE_INTERPROCEDURAL_OPTIMIZATION true )

set( TNUN_compiler_debug_symbols      -g                             )
set( TNUN_compiler_LTO                -flto                          )
set( TNUN_linker_LTO                  -flto                          )
set( TNUN_compiler_fastmath           -ffast-math -ffp-contract=fast )
set( TNUN_compiler_rtti_on            -frtti                         )
set( TNUN_compiler_rtti_off           -fno-rtti                      )
set( TNUN_compiler_exceptions_on      -fexceptions                   )
set( TNUN_compiler_exceptions_off     -fno-exceptions                )
set( TNUN_compiler_optimize_for_speed -O3 -funroll-loops             )

set( TNUN_compiler_release_flags -DNDEBUG -fomit-frame-pointer -ffunction-sections -fdata-sections -fmerge-all-constants -fno-stack-protector )

add_compile_options( -fstrict-aliasing -fstrict-enums -fvisibility=hidden -fvisibility-inlines-hidden -fno-threadsafe-statics -Wall -Wstrict-aliasing -Wno-multichar -Wno-unknown-pragmas -Wno-delete-non-virtual-dtor -Wno-unused-local-typedefs )

# "Unknown language" error with CMake 3.5.2 if COMPILE_LANGUAGE:C is used.
# + 'COMPILE_LANGUAGE' isn't supported by VS generators:
# https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#logical-expressions
add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++1z> $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:-std=gnu11> )
