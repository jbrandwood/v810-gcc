#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 6 of 8 - Build NEWLIB using the minimal GCC that we compiled.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_newlib.sh again.
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
# Set the target compiler flags
#---------------------------------------------------------------------------------

export CFLAGS='-O2'
export CXXFLAGS='-O2'

if [ "$OS" = "Windows_NT" ] ; then
  export LDFLAGS='-Wl,-Bstatic'
else
  export LDFLAGS=
fi

#---------------------------------------------------------------------------------
# Build and install newlib
#---------------------------------------------------------------------------------

cd $GITDIR/build/newlib

make --jobs=$(nproc) all 2>&1 | tee newlib_make.log

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
