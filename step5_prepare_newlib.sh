#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 5 of 8 - Unpack, patch and configure NEWLIB.
#

OSNAME=`uname -s`

TARGET=v810

GITDIR=$(pwd)
echo GITDIR is $GITDIR

export DSTDIR=$GITDIR/$TARGET-gcc
echo DSTDIR is $DSTDIR

mkdir -p $DSTDIR/bin
export PATH=$DSTDIR/bin:$PATH

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

TestFile "archive/newlib-2.2.0-1.tar.gz";

TestFile "patch/newlib-2.2.0-1-01-v810.patch";
TestFile "patch/newlib-2.2.0-1-02-v810-memcpy.patch";

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

PrepareSource()
{
  if [ -e  newlib-2.2.0-1 ] ; then
    rm -rf newlib-2.2.0-1
  fi

  if [ -e  build/newlib ] ; then
    rm -rf build/newlib
  fi

  tar zxvf archive/newlib-2.2.0-1.tar.gz
  cd newlib-2.2.0-1

  patch -p 1 -i ../patch/newlib-2.2.0-1-v810.patch
  patch -p 1 -i ../patch/newlib-2.2.0-1-v810-memcpy.patch

  cd ..
}

if [ -d newlib-2.2.0-1 ] ; then
  if [ "${1}" = "clean" ] ; then
    PrepareSource
  fi
else
  PrepareSource
fi

if [ -d build/newlib ] ; then
  rm -rf build/newlib
fi

#---------------------------------------------------------------------------------
# Set the target compiler flags
#---------------------------------------------------------------------------------

export CFLAGS='-O2'
export CXXFLAGS='-O2'

if [ "$OS" = "Windows_NT" ] ; then
  export LDFLAGS='-Wl,-Bstatic'
else
  export LDFLAGS=
fi

if [ "$OSNAME" = "Darwin" ] ; then
  BUILD='--build=x86_64-apple-darwin20'
else
  BUILD=
fi

#---------------------------------------------------------------------------------
# Build and install binutils
#---------------------------------------------------------------------------------

# Compiling on Windows (mingw/cygwin) requires that this configure is invoked
# from a relative path and not an absolute path. Linux doesn't care.

export SRCDIR=../../newlib-2.2.0-1

export TMPDIR=$GITDIR/build/newlib

mkdir -p $TMPDIR
cd $TMPDIR

$SRCDIR/configure                       \
  --prefix=$DSTDIR                      \
  $BUILD --target=$TARGET               \
  --disable-multilib                    \
  --disable-newlib-multithread          \
  --disable-newlib-iconv                \
  --disable-newlib-fvwrite-in-streamio  \
  --disable-newlib-fseek-optimization   \
  --disable-newlib-wide-orient          \
  --disable-newlib-io-float             \
  --disable-newlib-atexit-dynamic-alloc \
  --disable-newlib-supplied-syscalls    \
  --enable-newlib-global-atexit         \
  --enable-newlib-nano-formatted-io     \
  --enable-newlib-nano-malloc           \
  --enable-newlib-reent-small           \
  --enable-lite-exit                    \
  --enable-newlib-hw-fp                 \
  2>&1 | tee newlib_configure.log

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
