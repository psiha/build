################################################################################
#
# T:N.U.N. Visual Studio/MSVC CMake tool chain file.
#
# Copyright (c) 2016. Domagoj Saric. All rights reserved.
#
################################################################################

set( TNUN_compiler_debug_symbols      /Zi                                         )
set( TNUN_linker_debug_symbols        /DEBUG                                      )
set( TNUN_compiler_LTO                /GL                                         )
set( TNUN_linker_LTO                  /LTCG                                       )
set( TNUN_compiler_fastmath           /fp:except- /fp:fast /Qfast_transcendentals )
set( TNUN_compiler_rtti_on            /GR                                         )
set( TNUN_compiler_rtti_off           /GR-                                        )
set( TNUN_compiler_exceptions_on      /EHsc                                       )
set( TNUN_compiler_exceptions_off     /wd4577                                     )
set( TNUN_compiler_optimize_for_speed /Ox /Ot /Qvec-report:2                      )

set( TNUN_compiler_release_flags /DNDEBUG /Bt /Ox /Ob2 /Oy /GF /Gw /Gm- /GS- /Gy /Qpar )

add_compile_options( /MP /Oi /W4 /Zc:threadSafeInit- /wd4324 ) # w4324 = 'structure was padded due to alignment specifier'
add_definitions(
    -D_CRT_SECURE_NO_WARNINGS
    -D_SBCS
    -D_WIN32_WINNT=0x0601 # Win7
)