#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 3 of 6 - Unpack, patch and configure the initial minimal GCC.
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

TestFile "archive/gcc-4.9.4.tar.bz2";
TestFile "archive/cloog-0.18.5.tar.gz";
TestFile "archive/isl-0.18.tar.bz2";
TestFile "archive/gmp-6.1.2.tar.bz2";
TestFile "archive/mpc-1.0.3.tar.gz";
TestFile "archive/mpfr-3.1.6.tar.bz2";

TestFile "patch/gcc-4.9.4-no-iconv.patch";
TestFile "patch/gcc-4.9.4-texi.patch";
TestFile "patch/gcc-4.9.4-cpp17.patch";
TestFile "patch/gcc-4.9.4-fix-warnings.patch";
TestFile "patch/gcc-4.9.4-rmv-warnings.patch";
TestFile "patch/gcc-4.9.4-v810.patch";

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

PrepareSource()
{
  if [ -e  gcc-4.9.4 ]; then
    rm -rf gcc-4.9.4
  fi

  tar -xvjf archive/gcc-4.9.4.tar.bz2
  cd gcc-4.9.4

  tar -xzf ../archive/cloog-0.18.5.tar.gz
  mv cloog-0.18.5 cloog

  tar -xjf ../archive/isl-0.18.tar.bz2
  mv isl-0.18 isl

  tar -xjf ../archive/gmp-6.1.2.tar.bz2
  mv gmp-6.1.2 gmp

  tar -xzf ../archive/mpc-1.0.3.tar.gz
  mv mpc-1.0.3 mpc

  tar -xjf ../archive/mpfr-3.1.6.tar.bz2
  mv mpfr-3.1.6 mpfr

  patch -p 1 -i ../patch/gcc-4.9.4-no-iconv.patch
  patch -p 1 -i ../patch/gcc-4.9.4-texi.patch
  patch -p 1 -i ../patch/gcc-4.9.4-cpp17.patch
  patch -p 1 -i ../patch/gcc-4.9.4-fix-warnings.patch
  patch -p 1 -i ../patch/gcc-4.9.4-rmv-warnings.patch
  patch -p 1 -i ../patch/gcc-4.9.4-v810.patch

  cd ..
}

if [ -d gcc-4.9.4 ] ; then
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
# Set the target compiler flags
#---------------------------------------------------------------------------------

if [ "$OS" = "Windows_NT" ] ; then
  export CFLAGS='-O2 -static'
  export CXXFLAGS='-O2 -static'
  export LDFLAGS='-Wl,-Bstatic'
# export LDFLAGS='-Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive'
  BUILD=
else
  export CFLAGS='-O2'
  export CXXFLAGS='-O2'
  export LDFLAGS=
if [ "$OSNAME" = "Linux" ] ; then
  BUILD='--build=x86_64-linux-gnu'
else
if [ "$OSNAME" = "Darwin" ] ; then
  BUILD='--build=x86_64-apple-darwin20'
fi
fi
fi

#---------------------------------------------------------------------------------
# Build a minimal GCC to compile newlib
#---------------------------------------------------------------------------------

# Compiling on Windows (mingw/cygwin) requires that this configure is invoked
# from a relative path and not an absolute path. Linux doesn't care.

export SRCDIR=../../gcc-4.9.4

export TMPDIR=$GITDIR/build/gcc

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
  $BUILD --target=$TARGET                      \
  --prefix=$DSTDIR                             \
  --without-headers                            \
  --with-newlib                                \
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
  --enable-languages=c                         \
  2>&1 | tee gcc_configure.log

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
