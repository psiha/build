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

// PSI_PURE_MAY_THROW / PSI_CONST_MAY_THROW - [[gnu::pure]] / [[gnu::const]]
// for a function that can throw (a lookup that throws on a missing key, a
// checked conversion that throws on bad input). A function that cannot throw
// uses the plain attribute.
//
// - GCC: pure and const restrict what a function may read and write; they do
//   not make it nothrow (that is the separate nothrow attribute). A call of a
//   throwing pure/const function keeps its unwind entry, so the exception
//   reaches the caller's handlers and cleanups (checked with GCC 16 at -O2
//   and -O3). The documentation does not say so explicitly; the GCC
//   developers state it is intended
//   (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100409#c8). As with any
//   pure/const call, a call whose result is unused may be removed together
//   with its throw, and repeated calls with the same arguments may be merged.
//   The C23-style [[gnu::reproducible]] / [[gnu::unsequenced]] (GCC 15+, also
//   accepted in C++, unwinding kept) are not used instead: C23 lets such a
//   function modify objects reached through pointer arguments, so GCC merges
//   repeated calls only when every argument is passed by value - not with
//   reference parameters or member functions (this), where pure/const do merge.
//   Clang implements neither attribute (llvm-project#84406).
//
// - Clang (including Clang-CL; __clang__ must be checked before __GNUC__,
//   which Clang also defines): the frontend marks every pure and const
//   function nounwind
//   (https://github.com/llvm/llvm-project/blob/c649ccf1449e8f3af0fa5d38df212bd8af6ef51d/clang/lib/CodeGen/CGCall.cpp#L2841-L2858),
//   so a call of one is emitted with no unwind entry: an exception thrown out
//   of it is undefined behaviour (std::terminate, or cleanups for the wrong
//   code region). The same holds for __declspec(noalias). The macros expand
//   to nothing there until Clang keeps the memory effects without implying
//   nounwind (https://github.com/llvm/llvm-project/issues/50365).
//
// - MSVC (real cl.exe): no attribute gives call merging. __declspec(noalias)
//   has different semantics (only first-level pointer-parameter memory, no
//   globals) and buys no call merging on cl.exe; nothing.
#if defined( __clang__ )
#   define PSI_PURE_MAY_THROW
#   define PSI_CONST_MAY_THROW
#elif defined( __GNUC__ )
#   define PSI_PURE_MAY_THROW  [[ gnu::pure  ]]
#   define PSI_CONST_MAY_THROW [[ gnu::const ]]
#else
#   define PSI_PURE_MAY_THROW
#   define PSI_CONST_MAY_THROW
#endif

// PSI_LIFETIMEBOUND - the result of a function (or the object a constructor
// makes) refers to what the marked parameter refers to, so a compiler that
// knows the attribute warns when that parameter is bound to a temporary that
// dies first (a view returned from a temporary container, a span made from
// one). It goes after the declarator id of a parameter
// (`T const & range PSI_LIFETIMEBOUND`), or after the qualifiers (and the
// noexcept-specifier) of a member function, where it marks the object the
// function is called on (`T * data() noexcept PSI_LIFETIMEBOUND`).
//
// - Clang (including Clang-CL, which takes this branch first):
//   [[clang::lifetimebound]], checked by -Wdangling and its relatives.
//
// - MSVC (real cl.exe): [[msvc::lifetimebound]] where the compiler reports
//   it, checked by the /analyze lifetime rules.
//
// - GCC: no such attribute (-Wdangling-reference is a heuristic, which
//   [[gnu::no_dangling]] only silences); nothing.
#if __has_cpp_attribute( clang::lifetimebound )
#   define PSI_LIFETIMEBOUND [[ clang::lifetimebound ]]
#elif __has_cpp_attribute( msvc::lifetimebound )
#   define PSI_LIFETIMEBOUND [[ msvc::lifetimebound ]]
#else
#   define PSI_LIFETIMEBOUND
#endif
