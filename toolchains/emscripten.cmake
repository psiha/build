################################################################################
#
# T:N.U.N. Emscripten toolchain file.
#
# Copyright (c) 2019. Nenad miksa. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

set( TNUN_compiler_debug_symbols -g4 "SHELL:-s DEMANGLE_SUPPORT=1" )
set( TNUN_linker_debug_symbols   -g4 "SHELL:-s DEMANGLE_SUPPORT=1" )

set( TNUN_linker_exceptions_on  "SHELL:-s DISABLE_EXCEPTION_CATCHING=0" )
set( TNUN_linker_exceptions_off "SHELL:-s DISABLE_EXCEPTION_CATCHING=1" )

list( APPEND TNUN_compiler_exceptions_on  ${TNUN_linker_exceptions_on}  )
list( APPEND TNUN_compiler_exceptions_off ${TNUN_linker_exceptions_off} )

# use that on fastcomp - upstream backend does this out of the box when -flto is specified and whines about --llvm-lto flag being ignored
string( REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION} )
list( GET VERSION_LIST 0 clang_major_version  )
if ( ${clang_major_version} EQUAL 6 )
    list( APPEND TNUN_linker_LTO "SHELL:--llvm-lto 3" "SHELL:--llvm-opts 3")
endif()

set( TNUN_compiler_assertions "SHELL:-s ASSERTIONS=2" "SHELL:-s STACK_OVERFLOW_CHECK=2" "SHELL:-s GL_ASSERTIONS=1" "SHELL:-s SAFE_HEAP=1" )
set( TNUN_linker_assertions ${TNUN_compiler_assertions} )

list( APPEND TNUN_compiler_release_flags "SHELL:-s ASSERTIONS=0" "SHELL:-s STACK_OVERFLOW_CHECK=0" )
list( APPEND TNUN_linker_release_flags ${TNUN_compiler_release_flags} "SHELL:--closure 1" "SHELL:-s IGNORE_CLOSURE_COMPILER_ERRORS=1" )

set( CMAKE_EXECUTABLE_SUFFIX ".html" )

# depending on ABORTING_MALLOC and ALLOW_MEMORY_GROWTH emscripten settings
# see: https://github.com/emscripten-core/emscripten/blob/master/src/settings.js

set( TNUN_MALLOC_OVERCOMMIT_POLICY Partial )

if ( NOT ${clang_major_version} EQUAL 6 )
# always use STRICT mode if not using fastcomp (on fastcomp with 1.39.16 it's broken): https://github.com/emscripten-core/emscripten/blob/1.38.43/src/settings.js#L809
    set( strict_mode "SHELL:-s STRICT=1" )
    add_compile_options( ${strict_mode} )
    add_link_options( ${strict_mode} )
endif()

add_compile_options( -fno-PIC )

# always use emmalloc, instead of default dlmalloc
# https://groups.google.com/g/emscripten-discuss/c/SCZMkfk8hyk?pli=1
# https://github.com/emscripten-core/emscripten/blob/2.0.12/src/settings.js#L121
add_link_options( "SHELL:-s MALLOC=emmalloc" )
