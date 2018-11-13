# v810-gcc
Patches and build scripts to make a GCC4 toolchain for the NEC V810 cpu used in the NEC PC-FX and Nintendo VirtualBoy.

The toolchain can currently be built only on Windows using MSYS2 and mingw-w64 (https://www.msys2.org/). That will hopefully be fixed soon.


## Directory Layout

Source code ...

*<some_directory>*/src/v810-gcc/

Toolchain output ...

*<some_directory>*/bin/v810-gcc/


## Building with MSYS2

Install the base MSYS2 system.
Install the "base-devel" package.

cd *<some_directory>*/src/v810-gcc/
./build_compiler.sh
