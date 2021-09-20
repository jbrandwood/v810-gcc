#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 1 of 8 - Unpack, patch and configure BINUTILS.
#

OSNAME=`uname`

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

TestFile "archive/binutils-2.24.tar.bz2";

TestFile "patch/binutils-2.24-gcc-4.9.patch";
TestFile "patch/binutils-2.24-gcc-8.0.patch";
TestFile "patch/binutils-2.24-gcc-10.0.patch";
TestFile "patch/binutils-2.24-v810.patch";

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

PrepareSource()
{
  if [ -e  binutils-2.24 ] ; then
    rm -rf binutils-2.24
  fi

  if [ -e  build/binutils ] ; then
    rm -rf build/binutils
  fi

  tar jxvf archive/binutils-2.24.tar.bz2
  cd binutils-2.24

  patch -p 1 -i ../patch/binutils-2.24-gcc-4.9.patch
  patch -p 1 -i ../patch/binutils-2.24-gcc-8.0.patch
  patch -p 1 -i ../patch/binutils-2.24-gcc-10.0.patch
  patch -p 1 -i ../patch/binutils-2.24-v810.patch

  cd ..
}

if [ -d binutils-2.24 ] ; then
  if [ "${1}" = "clean" ] ; then
    PrepareSource
  fi
else
  PrepareSource
fi

if [ -d build/binutils ] ; then
  rm -rf build/binutils
fi

#---------------------------------------------------------------------------------
# Set the target and compiler flags
#---------------------------------------------------------------------------------

# Building the toolchain to compile for the NEC V810 cpu.



TARGET=v810

export CFLAGS='-O2'
export CXXFLAGS='-O2'

if [ "$OSNAME" = "Linux" ] ; then
  export LDFLAGS=
else
  export LDFLAGS='-Wl,-Bstatic'
fi

#---------------------------------------------------------------------------------
# Build and install binutils
#---------------------------------------------------------------------------------

# Compiling on Windows (mingw/cygwin) requires that this configure is invoked
# from a relative path and not an absolute path. Linux doesn't care.

export SRCDIR=../../binutils-2.24

export DSTDIR=$TOPDIR/../../bin/$TARGET-gcc

mkdir -p $DSTDIR/bin
export PATH=$DSTDIR/bin:$PATH

export TMPDIR=$TOPDIR/build/binutils

mkdir -p $TMPDIR
cd $TMPDIR

$SRCDIR/configure             \
  --target=$TARGET            \
  --prefix=$DSTDIR            \
  --with-lib-path=$DSTDIR/lib \
  --disable-nls               \
  --disable-shared            \
  --disable-multilib          \
  --disable-lto               \
  2>&1 | tee binutils_configure.log

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
