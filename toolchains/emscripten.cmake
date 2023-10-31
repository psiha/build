################################################################################
#
# PSI Emscripten toolchain file.
#
# Copyright (c) 2019. Nenad miksa. All rights reserved.
#
################################################################################

include( "${CMAKE_CURRENT_LIST_DIR}/clang.cmake" )

if ( EMSCRIPTEN_VERSION VERSION_GREATER_EQUAL "3.1.32" )
    set( PSI_debug_symbols -g )
elseif ( EMSCRIPTEN_VERSION VERSION_GREATER_EQUAL "2.0.17" )
    set( PSI_debug_symbols -g3 -gsource-map )
else()
    set( PSI_debug_symbols -g4 )
endif()

set( PSI_compiler_debug_symbols ${PSI_debug_symbols} )
set( PSI_linker_debug_symbols   ${PSI_debug_symbols} "SHELL:-s DEMANGLE_SUPPORT=1" )

set( PSI_linker_exceptions_on  "SHELL:-s DISABLE_EXCEPTION_CATCHING=0" )
set( PSI_linker_exceptions_off "SHELL:-s DISABLE_EXCEPTION_CATCHING=1" )

list( APPEND PSI_compiler_exceptions_on  ${PSI_linker_exceptions_on}  )
list( APPEND PSI_compiler_exceptions_off ${PSI_linker_exceptions_off} )

set( PSI_linker_assertions "SHELL:-s ASSERTIONS=2" "SHELL:-s STACK_OVERFLOW_CHECK=2" "SHELL:-s GL_ASSERTIONS=1" "SHELL:-s SAFE_HEAP=1" )

list( APPEND PSI_linker_release_flags "SHELL:-s ASSERTIONS=0" "SHELL:-s STACK_OVERFLOW_CHECK=0" "SHELL:--closure 1" "SHELL:-s IGNORE_CLOSURE_COMPILER_ERRORS=1" )

set( CMAKE_EXECUTABLE_SUFFIX ".html" )

# depending on ABORTING_MALLOC and ALLOW_MEMORY_GROWTH emscripten settings
# see: https://github.com/emscripten-core/emscripten/blob/master/src/settings.js

set( PSI_MALLOC_OVERCOMMIT_POLICY Partial )

# always use STRICT mode
set( strict_mode "SHELL:-s STRICT=1" )
list( APPEND PSI_common_compiler_options ${strict_mode} )
list( APPEND PSI_common_link_options     ${strict_mode} )

list( APPEND PSI_common_compiler_options -fno-PIC )

# always use emmalloc, instead of default dlmalloc
# https://groups.google.com/g/emscripten-discuss/c/SCZMkfk8hyk?pli=1
# https://github.com/emscripten-core/emscripten/blob/2.0.12/src/settings.js#L121
list( APPEND PSI_common_link_options "SHELL:-s MALLOC=emmalloc" )
