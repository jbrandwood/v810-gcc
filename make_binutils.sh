#!/bin/sh
#
# Build script for V810-GCC.
#
# Stage 2 of 8 - Build BINUTILS.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_binutils.sh again.
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
# Build and install binutils
#---------------------------------------------------------------------------------

export DSTDIR=$TOPDIR/../../bin/$TARGET-gcc

cd $TOPDIR/build/binutils

make --jobs=3 all 2>&1 | tee binutils_make.log

if [ $? != 0 ]; then
  echo "Error: building binutils";
  exit 1;
fi

make install-strip 2>&1 | tee binutils_install.log

if [ $? != 0 ]; then
  echo "Error: installing binutils";
  exit 1;
fi

cd ../../

#---------------------------------------------------------------------------------
# Remove duplicate/unnecessary files to save space
#---------------------------------------------------------------------------------

rm $DSTDIR/bin/$TARGET-ld.bfd.exe
rm $DSTDIR/$TARGET/bin/ld.bfd.exe

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
