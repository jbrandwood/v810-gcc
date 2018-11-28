#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 7 of 8 - Configure the final version GCC now that NEWLIB exists.
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

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

if [ ! -d gcc-4.7.4 ] ; then
  echo
  echo "$0 failed, the patched gcc-4.7.4 directory is missing!"
  exit 1
fi

if [ -d build/gcc ] ; then
  rm -rf build/gcc
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
# Build full GCC now that we've got newlib
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
  --with-local-prefix=$DESTDIR                 \
  --with-native-system-header=$DESTDIR/include \
  --disable-shared                             \
  --enable-static                              \
  --disable-pedantic                           \
  --disable-nls                                \
  --disable-multilib                           \
  --disable-decimal-float                      \
  --disable-libgomp                            \
  --disable-libitm                             \
  --disable-libssp                             \
  --disable-libstdc++-v3                       \
  --disable-libquadmath                        \
  --disable-lto                                \
  --enable-frame-pointer                       \
  --enable-languages=c,c++                     \
  2>&1 | tee gcc_configure.log

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
