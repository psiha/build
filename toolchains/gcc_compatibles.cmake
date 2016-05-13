################################################################################
#
# T:N.U.N. build options common to all GCC-compatible compilers.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( CMAKE_VISIBILITY_INLINES_HIDDEN    true )
set( CMAKE_INTERPROCEDURAL_OPTIMIZATION true )

set( TNUN_compiler_debug_symbols      -g                               )
set( TNUN_compiler_LTO                -flto                            )
set( TNUN_linker_LTO                  -flto                            )
set( TNUN_compiler_fastmath           "-ffast-math -ffp-contract=fast" )
set( TNUN_compiler_rtti_on            -frtti                           )
set( TNUN_compiler_rtti_off           -fno-rtti                        )
set( TNUN_compiler_exceptions_on      -fexceptions                     )
set( TNUN_compiler_exceptions_off     -fno-exceptions                  )
set( TNUN_compiler_optimize_for_speed "-O3 -funroll-loops"             )


set( CMAKE_C_FLAGS "-fstrict-aliasing -fstrict-enums -fvisibility=hidden -fvisibility-inlines-hidden -fno-threadsafe-statics -Wall -Wstrict-aliasing -Wno-unused-function -Wno-multichar -Wno-unknown-pragmas -Wno-delete-non-virtual-dtor -Wno-unused-local-typedefs" )
set( CMAKE_C_FLAGS_RELEASE "-fomit-frame-pointer -ffunction-sections -fdata-sections -fmerge-all-constants -fno-stack-protector" )

set( CMAKE_CXX_FLAGS         "${CMAKE_C_FLAGS}"         )
set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" )

set( CMAKE_C_FLAGS   "-std=gnu11"   )
set( CMAKE_CXX_FLAGS "-std=gnu++1z" )