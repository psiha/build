# Introduction

Reusable components for cross-platform project builds.

## Prerequisites

[CMake](http://cmake.org)

[Tutorial](http://cmake.org/cmake-tutorial)

## Standard/common procedure for setting up a project build with CMake
* Open CMake.
* Set the source code folder to the "source" folder (the one containing
  the CMakeLists.txt file).
* Set the binary folder according to your preference (this is where
  the platform & IDE specific files will be placed, like Visual Studio
  solution&project files).
* Press "Configure".
* Choose the desired generator (and toolchain file if crosscompiling).
* Press "Configure".
* Press "Generate".
* CMake can (but does not have to) be closed at this point.
* Open the generated native project using the appropriate IDE.

## LTO link-time knobs

`lto_link_knobs.cmake` applies the options that steer the LTO backend (`--lto-O`/`--lto-CGO`,
linker `-O`, ICF, inline threshold, vectorizer switches, machine outliner, hot/cold splitting) at the
link, where the whole-program pipeline runs, instead of at the per-translation-unit compile:

* `PSI_lto_link_knobs( <target>... )` applies them to given targets, `PSI_lto_link_knobs_in_directory( <dir> )`
  to every target of a directory tree (e.g. a third party project added with `add_subdirectory()`);
  the values come from the `PSI_BUILD_*` cache variables or from keyword arguments.
* `cmake -DPSI_BUILD_...=... -DPSI_BUILD_FORMAT=rustc -P lto_link_knobs.cmake` prints the same options
  for consumers that are not CMake builds (linker options, compile step options or `rustc` flags).

A link-time inline threshold governs the calls still pending at link (mostly the ones across translation
units); inside a translation unit the compile step has already inlined at the default threshold, so lowering
it there takes the compile-step option too (`COMPILE_INLINE_THRESHOLD`, independent of the link-time value). The header of the file explains this, the platform branches
(ELF/Mach-O lld and clang-cl lld-link) and the caveats.

## Standard development environment
* Tools:
    * [CMake](http://cmake.org)
    * [Doxygen](http://www.doxygen.org)
    * [Git](http://www.git-scm.com)
    * [TortoiseGit](https://tortoisegit.org)
    * [Notepad++](https://notepad-plus-plus.org) (recommended for editing CMake scripts)
    * supported/tested platforms:
        * Windows - Visual Studio
        * OS X    - Xcode
        * iOS     - toolchains/ios.readme.txt
        * Android - toolchains/android/readme.txt


## Standard release procedure
1. Make sure you have a clean source tree of the project and all
   submodules and 3rd party libraries.
2. Update the product's "Release notes" documentation section with the
   changes for this version.
3. Create an appropriate branch/tag for the released version.
4. Build the "Release" build/version of the "PACKAGE" target.
5. Test/verify.
6. Publish.

## Related/similar endeavours

* http://nickhutchinson.me/cmake-toolkit