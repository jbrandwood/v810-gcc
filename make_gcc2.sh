#!/bin/sh
#
# Build script for V810-GCC.
#
# Stage 8 of 8 - Build the final version of GCC now that NEWLIB exists.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_gcc2.sh again.
#

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

#---------------------------------------------------------------------------------
# Set the target and compiler flags
#---------------------------------------------------------------------------------

# Building the toolchain to compile for the NEC V810 cpu.

TARGET=v810

export CFLAGS='-O2 -pipe'
export CXXFLAGS='-O2 -pipe'
export LDFLAGS='-Wl,-Bstatic'

#---------------------------------------------------------------------------------
# Setup the toolchain for linux
#---------------------------------------------------------------------------------

export DSTDIR=$TOPDIR/../../bin/$TARGET-gcc

mkdir -p $DSTDIR/bin
export PATH=$DSTDIR/bin:$PATH

#---------------------------------------------------------------------------------
# Build a minimal GCC
#---------------------------------------------------------------------------------

cd $TOPDIR/build/gcc

make --jobs=3 all 2>&1 | tee gcc_make.log

if [ $? != 0 ]; then
  echo "Error: building gcc";
  exit 1;
fi

make install-strip 2>&1 | tee gcc_install.log

if [ $? != 0 ]; then
  echo "Error: installing gcc";
  exit 1;
fi

cd ../../

#---------------------------------------------------------------------------------
# Remove duplicate/unnecessary files to save space
#---------------------------------------------------------------------------------

rm $DSTDIR/bin/$TARGET-gcc-4.7.4.exe
rm $DSTDIR/bin/$TARGET-gcc-ar.exe
rm $DSTDIR/bin/$TARGET-gcc-nm.exe
rm $DSTDIR/bin/$TARGET-gcc-ranlib.exe

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
