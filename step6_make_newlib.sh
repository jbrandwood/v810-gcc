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
OSARCH=`uname -m`

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

if [ "$OS" = "Windows_NT" ] ; then
  JOBS=$(nproc)
else
  if [ "$OSNAME" = "Linux" ] ; then
    JOBS=$(nproc)
  else
    if [ "$OSNAME" = "Darwin" ] ; then
      JOBS=`sysctl -n hw.logicalcpu`
    fi
  fi
fi

#---------------------------------------------------------------------------------
# Build and install newlib
#---------------------------------------------------------------------------------

cd $GITDIR/build/newlib

make --jobs=$JOBS all 2>&1 | tee newlib_make.log

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
