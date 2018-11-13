#!/bin/sh
#
# Use this to download the GNU source code files and then build the whole V810 GCC
# toolchain in a single step.
#
# If things break or don't compile, then you can look at this file as a template
# for the individual steps that you need to take to fix things.
#

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

rm -rf build

mkdir -p archive
pushd archive

if [ ! -e  binutils-2.24.tar.bz2 ] ; then
  echo
  echo "Downloading binutils-2.24.tar.bz2 from ftp.gnu.org";
  curl.exe -L -O -R https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the binutils source";
    rm binutils-2.24.tar.bz2
    exit 1;
  fi
fi

if [ ! -e  gcc-4.7.4.tar.bz2 ] ; then
  echo
  echo "Downloading gcc-4.7.4.tar.bz2 from ftp.gnu.org";
  curl.exe -L -O -R https://ftp.gnu.org/gnu/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the gcc source";
    rm gcc-4.7.4.tar.bz2
    exit 1;
  fi
fi

if [ ! -e  newlib-2.2.0-1.tar.gz ] ; then
  echo
  echo "Downloading newlib-2.2.0-1.tar.gz from sourceware.org";
  curl.exe -L -O -R ftp://sourceware.org/pub/newlib/newlib-2.2.0-1.tar.gz

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the newlib source";
    rm newlib-2.2.0-1.tar.gz
    exit 1;
  fi
fi

popd

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
