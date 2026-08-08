#pragma once

// PSI_NO_UNIQUE_ADDRESS - a portable spelling of [[no_unique_address]] that
// also works under the MSVC ABI (real cl.exe and Clang-CL alike).
//
// The standard [[no_unique_address]] has no effect under the MSVC ABI: MSVC
// keeps the attribute's layout impact opt-in (rather than defaulting to the
// standard behaviour, which would change existing struct layouts and so
// break binary compatibility with code built by older MSVC versions/
// [[no_unique_address]]-unaware compilers). Clang-CL follows the same rule
// when targeting the MSVC ABI (it defines both __clang__ and _MSC_VER - see
// disable_warnings.hpp for the same ordering note), even though plain Clang
// (GNU-style target) honours [[no_unique_address]] normally. Concretely,
// under Clang-CL [[no_unique_address]] is not merely a no-op: it is an
// *unrecognized* attribute ([-Wunknown-attributes]), which is a hard error
// under -Werror.
//
// [[msvc::no_unique_address]] is the MSVC-specific spelling that opts in to
// the layout effect on both real MSVC (from VS 17.5 / _MSC_VER 1935) and
// Clang-CL targeting the MSVC ABI. Older MSVC has no equivalent - this macro
// expands to nothing there, matching PSI_COLD's precedent of degrading to a
// no-op on toolchains with no portable equivalent.
#if defined( __clang__ ) && defined( _MSC_VER )
#   define PSI_NO_UNIQUE_ADDRESS [[ msvc::no_unique_address ]]
#elif defined( _MSC_VER ) && _MSC_VER >= 1935
#   define PSI_NO_UNIQUE_ADDRESS [[ msvc::no_unique_address ]]
#elif defined( _MSC_VER )
#   define PSI_NO_UNIQUE_ADDRESS
#else
#   define PSI_NO_UNIQUE_ADDRESS [[ no_unique_address ]]
#endif
