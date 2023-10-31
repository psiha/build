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