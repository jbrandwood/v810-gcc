#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 6 of 8 - Build NEWLIB using the minimal GCC that we compiled.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_newlib.sh again.
#

OSNAME=`uname`

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

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
# Build and install newlib
#---------------------------------------------------------------------------------

export DSTDIR=$TOPDIR/../../bin/$TARGET-gcc

mkdir -p $DSTDIR/bin
export PATH=$DSTDIR/bin:$PATH

cd $TOPDIR/build/newlib

make --jobs=3 all 2>&1 | tee newlib_make.log

if [ $? != 0 ]; then
  echo "Error: building newlib";
  exit 1;
fi

make install 2>&1 | tee newlib_install.log

if [ $? != 0 ]; then
  echo "Error: installing newlib";
  exit 1;
fi

cd ../../

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
