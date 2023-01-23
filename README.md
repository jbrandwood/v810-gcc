# v810-gcc
Patches and build scripts to make a GCC4 toolchain for the NEC V810 cpu used in the NEC PC-FX and Nintendo VirtualBoy videogame consoles.

The toolchain currently consists of ...
* binutils 2.27
* gcc 4.9.4
* newlib 2.2.0-1

The toolchain can currently be built on either Windows or Linux.


## Directory Layout

No particular host-machine output directory structure is assumed, and the build scripts output the compiler into the ./v810-gcc/ directory.

You can move the ./v810-gcc/ directory anywhere once the build process has finished.


## Building the Toolchain

Building a GCC cross-compiler toolchain (with an embedded cross-compiled C library) is frankly a bit of a nightmare.

It is an 8 step process, or 9 steps if you include downloading the source archives for the compiler and the libraries that it needs.

There is an overall build script called "build_compiler.sh" that calls all of the individual steps in order, but personally I prefer to run the steps one-at-a-time manually so that I can see and fix any errors/problems more easily.

The steps are ...
* step0_download_prereqs.sh
* step1_prepare_binutils.sh
* step2_make_binutils.sh
* step3_prepare_initial_gcc.sh
* step4_make_initial_gcc.sh
* step5_prepare_newlib.sh
* step6_make_newlib.sh
* step7_prepare_final_gcc.sh
* step8_make_final_gcc.sh


The "prepare" steps unpack the source-code archive for that step, then apply the V810 patches, and finally configure the source for compiling.

If the source-code directory already exists, then only the configuration is done.


The "make" steps actually compile the v810-gcc binaries for that step, and each "make" step can be rerun if you need to fix any build errors (i.e. edit a source file).


Intermediate files are put in the ./build/ directory tree, and you can look in there to find build log files for each step that you can use to help debug any build errors.

Once v810-gcc has been built, the ./build/ directory tree is not needed any more, and it can be deleted.

Running "./build_compiler.sh clean" will remove the "./build" directory, and also the unpacked-and-patched source code directories.


## Notes for building on Windows (with MSYS2)

Install the base MSYS2 system, either 32-bit or 64-bit, from [here](https://www.msys2.org/).

Install the "git", "base-devel", "autoconf" and "gperf" and packages.
```
pacman -Sy
pacman -S --needed git base-devel autoconf gperf
```

Install the compiler of your choice to build v810-gcc for either the base Microsoft MSVCRT or the newer Microsoft UCRT.

Either ...
```
pacman -S mingw-w64-x86_64-gcc
```
Or ...
```
pacman -S mingw-w64-ucrt-x86_64-gcc
```

Build the toolchain.
```
cd <some_directory>/v810-gcc/
./build_compiler.sh
```

Clean up the temporary directories.
```
./build_compiler.sh clean
```


## Notes for building on Linux (Debian or Ubuntu)

Install the "build-essential" package and other prerequisites ...
```
sudo apt-get install build-essential curl flex git gperf bison texinfo 
```

Build the toolchain.
```
cd <some_directory>/src/v810-gcc/
./build_compiler.sh
```

Clean up the temporary directories.
```
./build_compiler.sh clean
```
