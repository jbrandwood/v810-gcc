#!/bin/sh
#
# Build script for V810-GCC.
#
# Stage 3 of 6 - Unpack, patch and configure the initial minimal GCC.
#

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

#---------------------------------------------------------------------------------
# Check Prerequisites
#---------------------------------------------------------------------------------

## Test for executables
TestEXE()
{
  TEMP=`type $1`
  if [ $? != 0 ]; then
    echo "Error: $1 not installed";
    exit 1;
  fi
}

TestEXE "make";
TestEXE "gcc";
TestEXE "flex";
TestEXE "patch";
TestEXE "tar";
TestEXE "gzip";
TestEXE "autoconf";
TestEXE "gperf";
TestEXE "bison";

## Test for files to unpack
TestFile()
{
  if [ ! -f "$1" ]; then 
    echo "Error: $1 not found";
    exit 1;
  fi
}

TestFile "archive/gcc-4.7.4.tar.bz2";

TestFile "patch/gcc-4.7.4-gcc-5.0.patch";
TestFile "patch/gcc-4.7.4-less-warnings.patch";
TestFile "patch/gcc-4.7.4-no-iconv.patch";
TestFile "patch/gcc-4.7.4-texi.patch";
TestFile "patch/gcc-4.7.4-v810.patch";

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

PrepareSource()
{
  if [ -e  gcc-4.7.4 ]; then
    rm -rf gcc-4.7.4
  fi

  tar jxvf archive/gcc-4.7.4.tar.bz2
  cd gcc-4.7.4

  patch -p 1 -i ../patch/gcc-4.7.4-gcc-5.0.patch
  patch -p 1 -i ../patch/gcc-4.7.4-less-warnings.patch
  patch -p 1 -i ../patch/gcc-4.7.4-no-iconv.patch
  patch -p 1 -i ../patch/gcc-4.7.4-texi.patch
  patch -p 1 -i ../patch/gcc-4.7.4-v810.patch

  cd ..
}

if [ -d gcc-4.7.4 ] ; then
  if [ "${1}" = "clean" ] ; then
    PrepareSource
  fi
else
  PrepareSource
fi

if [ -d build/gcc ] ; then
  rm -rf build/gcc
fi

#---------------------------------------------------------------------------------
# Set the target and compiler flags
#---------------------------------------------------------------------------------

# Building the toolchain to compile for the NEC V810 cpu.

TARGET=v810

export CFLAGS='-O2 -pipe'
export CXXFLAGS='-O2 -pipe'
export LDFLAGS='-Wl,-Bstatic'

#---------------------------------------------------------------------------------
# Build a minimal GCC to compile newlib
#---------------------------------------------------------------------------------

# Compiling on Windows (mingw/cygwin) requires that this configure is invoked
# from a relative path and not an absolute path. Linux doesn't care.

export SRCDIR=../../gcc-4.7.4

export DSTDIR=$TOPDIR/../../bin/$TARGET-gcc

mkdir -p $DSTDIR/bin
export PATH=$DSTDIR/bin:$PATH

export TMPDIR=$TOPDIR/build/gcc

export TMPDIR=build/gcc

mkdir -p $TMPDIR
cd $TMPDIR

# Cross-GCC build configuration from
# www.linuxfromscratch.org/lfs/view/development/chapter05/gcc-pass1.html

# Note:
#
# Enable frame-pointer on V810 by default (disabled with -O, -O2, -O3, -Os).
# Frame pointer always enabled when -mprolog-function is used.

$SRCDIR/configure                              \
  --target=$TARGET                             \
  --prefix=$DSTDIR                             \
  --without-headers                            \
  --with-newlib                                \
  --with-local-prefix=$DESTDIR                 \
  --with-native-system-header=$DESTDIR/include \
  --disable-pedantic                           \
  --disable-nls                                \
  --disable-shared                             \
  --disable-multilib                           \
  --disable-decimal-float                      \
  --disable-libatomic                          \
  --disable-libcilkrts                         \
  --disable-libgomp                            \
  --disable-libitm                             \
  --disable-libsanitizer                       \
  --disable-libssp                             \
  --disable-libstdc++-v3                       \
  --disable-libquadmath                        \
  --disable-libvtv                             \
  --disable-lto                                \
  --enable-frame-pointer                       \
  --enable-languages=c                         \
  2>&1 | tee gcc_configure.log

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
