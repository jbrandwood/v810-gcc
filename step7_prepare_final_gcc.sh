#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 7 of 8 - Configure the final version GCC now that NEWLIB exists.
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

#---------------------------------------------------------------------------------
# Prepare Source and Install directories
#---------------------------------------------------------------------------------

if [ ! -d gcc-4.9.4 ] ; then
  echo
  echo "$0 failed, the patched gcc-4.9.4 directory is missing!"
  exit 1
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
# Build full GCC now that we've got newlib
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
