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

OSNAME=`uname`

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

rm -rf build

#---------------------------------------------------------------------------------
# Clean up the source & build directories?
#---------------------------------------------------------------------------------

if [ "${1}" = "clean" ] ; then
  if [ -e  build ] ; then
    rm -rf build
  fi
  if [ -e  binutils-2.24 ] ; then
    rm -rf binutils-2.24
  fi
  if [ -e  gcc-4.7.4 ] ; then
    rm -rf gcc-4.7.4
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
# Download the required library source files from GNU (on MacOSX)
#---------------------------------------------------------------------------------

mkdir -p archive
cd archive

if [ "$OSNAME" = "Darwin" ] ; then

  if [ ! -e  gmp-6.0.0a.tar.bz2 ] ; then
    echo
    echo "Downloading gmp-6.0.0a.tar.bz2 from ftp.gnu.org";
    curl -L -O -R https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2
  
    if [ $? != 0 ]; then
      echo "Error: Cannot download the required version of the gmp source";
      rm gmp-6.0.0a.tar.bz2
      cd ..
      exit 1;
    fi
  fi
  
  if [ ! -e  mpfr-3.1.2.tar.bz2 ] ; then
    echo
    echo "Downloading mpfr-3.1.2.tar.bz2 from ftp.gnu.org";
    curl -L -O -R https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.bz2
  
    if [ $? != 0 ]; then
      echo "Error: Cannot download the required version of the mpfr source";
      rm mpfr-3.1.2.tar.bz2
      cd ..
      exit 1;
    fi
  fi
  
  if [ ! -e  mpc-1.0.2.tar.gz ] ; then
    echo
    echo "Downloading mpc-1.0.2.tar.gz from ftp.gnu.org";
    curl -L -O -R https://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz
  
    if [ $? != 0 ]; then
      echo "Error: Cannot download the required version of the mpc source";
      rm mpc-1.0.2.tar.gz
      cd ..
      exit 1;
    fi
  fi

fi

cd ..

#---------------------------------------------------------------------------------
# Download the source files from GNU and Sourceware (Redhat)
#---------------------------------------------------------------------------------

mkdir -p archive
cd archive

if [ ! -e binutils-2.24.tar.bz2 ] ; then
  echo
  echo "Downloading binutils-2.24.tar.bz2 from ftp.gnu.org";
  curl -L -O -R https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the binutils source";
    rm binutils-2.24.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e gcc-4.7.4.tar.bz2 ] ; then
  echo
  echo "Downloading gcc-4.7.4.tar.bz2 from ftp.gnu.org";
  curl -L -O -R https://ftp.gnu.org/gnu/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the gcc source";
    rm gcc-4.7.4.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e newlib-2.2.0-1.tar.gz ] ; then
  echo
  echo "Downloading newlib-2.2.0-1.tar.gz from sourceware.org";
  curl -L -O -R ftp://sourceware.org/pub/newlib/newlib-2.2.0-1.tar.gz

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the newlib source";
    rm newlib-2.2.0-1.tar.gz
    cd ..
    exit 1;
  fi
fi

cd ..

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
