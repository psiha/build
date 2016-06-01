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

set( TNUN_compiler_debug_symbols      -g                                    )
set( TNUN_compiler_LTO                -flto                                 )
set( TNUN_linker_LTO                  -flto                                 )
set( TNUN_compiler_fastmath           -ffast-math -ffp-contract=fast -Ofast )
set( TNUN_compiler_rtti_on            -frtti                                )
set( TNUN_compiler_rtti_off           -fno-rtti                             )
set( TNUN_compiler_exceptions_on      -fexceptions                          )
set( TNUN_compiler_exceptions_off     -fno-exceptions                       )
set( TNUN_compiler_optimize_for_speed -O3 -funroll-loops                    )
set( TNUN_compiler_optimize_for_size  -Os                                   )

set( TNUN_compiler_release_flags -DNDEBUG -fomit-frame-pointer -ffunction-sections -fdata-sections -fmerge-all-constants -fno-stack-protector )

add_compile_options( -fstrict-aliasing -fstrict-enums -fvisibility=hidden -fvisibility-inlines-hidden -fno-threadsafe-statics -Wall -Wstrict-aliasing -Wno-multichar -Wno-unknown-pragmas -Wno-unused-local-typedefs )

# "Unknown language" error with CMake 3.5.2 if COMPILE_LANGUAGE:C is used.
# + 'COMPILE_LANGUAGE' isn't supported by VS generators:
# https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#logical-expressions
add_compile_options( $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++1z> )
add_compile_options( $<$<NOT:$<COMPILE_LANGUAGE:CXX>>:-std=gnu11> )

link_libraries( "-Wl,--no-undefined" "-Wl,-z,relro" "-Wl,-z,now" "-Wl,-z,nocopyreloc" )
link_libraries( $<$<CONFIG:RELEASE>:-Wl,--gc-sections> )
link_libraries( $<$<CONFIG:RELEASE>:-Wl,--icf=all>     ) # http://research.google.com/pubs/pub36912.html Safe ICF: Pointer Safe and Unwinding Aware Identical Code Folding in Gold
#-fuse-ld=gold ...mrmlj...does not work with Android NDK r11 (but should be the default)
