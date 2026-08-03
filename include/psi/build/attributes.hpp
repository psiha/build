#pragma once

// PSI_COLD - a portable "this function is rarely executed" attribute that
// also asks the compiler to optimize its body for size rather than speed.
//
// - GCC: [[gnu::cold]] already implies -Os-like codegen for the function
//   body (GCC's own docs: the cold attribute "informs the compiler that the
//   function is unlikely to be executed" and the function "is optimized for
//   size rather than speed").
//
// - Clang (this INCLUDES Clang-CL, which defines both __clang__ and
//   _MSC_VER - __clang__ must be checked before _MSC_VER, see
//   disable_warnings.hpp for the same ordering requirement):
//   [[gnu::cold]] is accepted but, unlike GCC, does NOT by itself trigger
//   size-optimized codegen - LLVM treats "cold" purely as a branch-
//   probability/code-layout hint, not a size directive. This is a
//   deliberate LLVM design choice, not an oversight or a bug to work around:
//   LLVM's own "[PGO] Add ability to mark cold functions as
//   optsize/minsize/optnone" patch series
//   (https://reviews.llvm.org/D149800) exists specifically because cold
//   alone buys no size reduction in LLVM, and a reviewer's comment on that
//   series states outright why it isn't the default - "fully using
//   minsize/optnone for cold funcs might have been too big of a hammer
//   performance-wise" - i.e. LLVM deliberately keeps the two concerns
//   (branch/layout hinting vs size optimization) separable rather than
//   coupling them the way GCC does. [[clang::minsize]] is the explicit
//   opt-in for the size-optimization half GCC gives you for free with cold
//   alone.
//
// - MSVC (real cl.exe, not Clang-CL): no equivalent function attribute was
//   found - no __declspec analogue for "cold" or "minsize" exists. PSI_COLD
//   expands to nothing there.
#if defined( __clang__ )
#   define PSI_COLD [[ gnu::cold, clang::minsize ]]
#elif defined( __GNUC__ )
#   define PSI_COLD [[ gnu::cold ]]
#else
#   define PSI_COLD
#endif
