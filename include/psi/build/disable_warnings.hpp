#pragma once

#define PSI_STRINGIZE( x ) #x

#if defined( __GNUC__ ) || defined( __clang__ ) // Clang-CL does not define __GNUC__ https://github.com/llvm/llvm-project/issues/53259

#   define PSI_WARNING_COMMAND( compiler, command, ... )	\
        _Pragma( PSI_STRINGIZE( compiler diagnostic command __VA_ARGS__ ) )

#   define PSI_WARNING_DISABLE_PUSH() PSI_WARNING_COMMAND( PSI_CMPLR, push )
#   define PSI_WARNING_DISABLE_POP( ) PSI_WARNING_COMMAND( PSI_CMPLR, pop  )

#ifdef __clang__
#   define PSI_CMPLR clang
#   define PSI_WARNING_CLANG_DISABLE( x ) PSI_WARNING_COMMAND( clang, ignored, #x )
#   define PSI_WARNING_GCC_DISABLE(   x )
#	ifdef _MSC_VER
#		define PSI_WARNING_CLANGCL_DISABLE( x ) PSI_WARNING_COMMAND( clang, ignored, #x )
#   else
#       define PSI_WARNING_CLANGCL_DISABLE( x )
#   endif
#else
#   define PSI_CMPLR GCC
#   define PSI_WARNING_GCC_DISABLE(     x ) PSI_WARNING_COMMAND( gcc, ignored, #x )
#   define PSI_WARNING_CLANG_DISABLE(   x )
#   define PSI_WARNING_CLANGCL_DISABLE( x )
#endif

#   define PSI_WARNING_GCC_OR_CLANG_DISABLE( x ) PSI_WARNING_COMMAND( PSI_CMPLR, ignored, #x )
#   define PSI_WARNING_MSVC_DISABLE(         x )

	// Predefined often used utilities
#	define PSI_WARNING_DISABLE_UNKNOWN_ATTRIBUTE()

#	define PSI_WARNING_DISABLE_ALL_PUSH()								\
        PSI_WARNING_COMMAND( PSI_CMPLR, push                         )	\
		PSI_WARNING_COMMAND( PSI_CMPLR, ignored, "-Wall"             )	\
		PSI_WARNING_COMMAND( PSI_CMPLR, ignored, "-Wextra"           )  \
        PSI_WARNING_COMMAND( PSI_CMPLR, ignored, "-Wnull-conversion" )	\
        PSI_WARNING_COMMAND( PSI_CMPLR, ignored, "-Wdocumentation"   )

#elif defined( _MSC_VER )

#	define PSI_WARNING_DISABLE_PUSH() _Pragma( "warning( push )" )
#	define PSI_WARNING_DISABLE_POP( ) _Pragma( "warning( pop  )" )

#	define PSI_WARNING_MSVC_DISABLE( x ) __pragma( warning( disable: x ) )

#	define PSI_WARNING_GCC_OR_CLANG_DISABLE( x )
#	define PSI_WARNING_GCC_DISABLE( x )
#	define PSI_WARNING_CLANG_DISABLE( x )
#	define PSI_WARNING_CLANGCL_DISABLE( x )

	// Predefined often used utilities
#	define PSI_WARNING_DISABLE_ALL_PUSH() _Pragma( "warning( push, 0 )" )

#	define PSI_WARNING_DISABLE_UNKNOWN_ATTRIBUTE() _Pragma( "warning( disable: 5030 )" )

#else
#	error "Unsupported compiler"
#endif

#define PSI_WARNING_DISABLE_UNKNOWN_ATTRIBUTE_PUSH()	\
	PSI_WARNING_DISABLE_PUSH()							\
	PSI_WARNING_DISABLE_UNKNOWN_ATTRIBUTE()
