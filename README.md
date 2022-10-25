# v810-gcc
Patches and build scripts to make a GCC4 toolchain for the NEC V810 cpu used in the NEC PC-FX and Nintendo VirtualBoy videogame consoles.

The toolchain currently consists of ...
* gcc 4.7.4
* newlib 2.2.0-1
* binutils 2.24

The toolchain can currently be built on either Windows or Linux.


## Directory Layout

Source code ...

<some_directory>/src/v810-gcc/

Toolchain output ...

<some_directory>/bin/v810-gcc/


## Building on Windows (with MSYS2)

Install the base MSYS2 system, either 32-bit or 64-bit, from [here](https://www.msys2.org/).

Install the "base-devel" and "git" packages.
```
pacman -Sy
pacman -S --needed base-devel git
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


## Building on Debian (Linux)

Install the "build-essential" package to get the compiler.
```
sudo apt-get install build-essential
```

Ubuntu systems will need to install additional packages needed for the build.
```
sudo apt-get install curl flex gperf bison texinfo
```

Install the static libraries that are needed to build GCC4.
```
sudo apt-get install libgmp-dev libmpc-dev libmpfr-dev
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
