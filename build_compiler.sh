#! /bin/sh
#
# Build script for V810-GCC.
#
# Use this to download the GNU source code files and then build the whole
# V810 GCC toolchain in a single step.
#
# If things break or don't compile, then you can look at this file as a
# template for the individual steps that you need to take to fix things.
#

OSNAME=`uname -s`

GITDIR=$(pwd)
echo GITDIR is $GITDIR

rm -rf build

#---------------------------------------------------------------------------------
# Clean up the source & build directories?
#---------------------------------------------------------------------------------

if [ "${1}" = "clean" ] ; then
  if [ -e  build ] ; then
    rm -rf build
  fi
  if [ -e  binutils-2.27 ] ; then
    rm -rf binutils-2.27
  fi
  if [ -e  gcc-4.9.4 ] ; then
    rm -rf gcc-4.9.4
  fi
  if [ -e  newlib-2.2.0-1 ] ; then
    rm -rf newlib-2.2.0-1
  fi
  exit 0
fi

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

TestEXE "curl";

#---------------------------------------------------------------------------------
# Download the source files from GNU and Sourceware (Redhat)
#---------------------------------------------------------------------------------

./download_prereqs.sh

if [ $? != 0 ]; then
  echo "Error: Failed to download source archives";
  exit 1;
fi

#---------------------------------------------------------------------------------
# Now go through the 8-stage build process
#---------------------------------------------------------------------------------

./prepare_binutils.sh clean

if [ $? != 0 ]; then
  echo "Error: Failed to prepare binutils";
  exit 1;
fi

./make_binutils.sh

if [ $? != 0 ]; then
  echo "Error: Failed to build binutils";
  exit 1;
fi

./prepare_gcc1.sh clean

if [ $? != 0 ]; then
  echo "Error: Failed to prepare initial gcc";
  exit 1;
fi

./make_gcc1.sh

if [ $? != 0 ]; then
  echo "Error: Failed to build initial gcc";
  exit 1;
fi

./prepare_newlib.sh clean

if [ $? != 0 ]; then
  echo "Error: Failed to prepare newlib";
  exit 1;
fi

./make_newlib.sh

if [ $? != 0 ]; then
  echo "Error: Failed to build newlib";
  exit 1;
fi

./prepare_gcc2.sh clean

if [ $? != 0 ]; then
  echo "Error: Failed to prepare final gcc";
  exit 1;
fi

./make_gcc2.sh

if [ $? != 0 ]; then
  echo "Error: Failed to build final gcc";
  exit 1;
fi

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
