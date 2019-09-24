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

list( APPEND TNUN_linker_LTO "SHELL:--llvm-lto 3" "SHELL:--llvm-opts 3")

set( TNUN_compiler_assertions "SHELL:-s ASSERTIONS=2" "SHELL:-s GL_ASSERTIONS=1" "SHELL:-s SAFE_HEAP=1" )
set( TNUN_linker_assertions ${TNUN_compiler_assertions} )

set( CMAKE_EXECUTABLE_SUFFIX ".html" )

# depending on ABORTING_MALLOC and ALLOW_MEMORY_GROWTH emscripten settings
# see: https://github.com/emscripten-core/emscripten/blob/master/src/settings.js

set( TNUN_MALLOC_OVERCOMMIT_POLICY Partial )

# always use STRICT mode: https://github.com/emscripten-core/emscripten/blob/1.38.43/src/settings.js#L809
set( strict_mode "SHELL:-s STRICT=1" )
add_compile_options( ${strict_mode} )
add_link_options( ${strict_mode} )
