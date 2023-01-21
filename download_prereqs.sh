#! /bin/sh
#
# Download script for V810-GCC.
#
# Use this to download the GNU source code files and libraries.
#

OSNAME=`uname -s`

SRCDIR=$(pwd)
echo SRCDIR is $SRCDIR

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

mkdir -p archive
cd archive

if [ ! -e binutils-2.27.tar.bz2 ] ; then
  echo
  echo "Downloading binutils-2.27.tar.bz2 from ftp.gnu.org mirror site";
  curl -L -O -R http://ftpmirror.gnu.org/binutils/binutils-2.27.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the binutils source";
    rm binutils-2.27.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e gcc-4.9.4.tar.bz2 ] ; then
  echo
  echo "Downloading gcc-4.9.4.tar.bz2 from ftp.gnu.org mirror site";
  curl -L -O -R http://ftpmirror.gnu.org/gcc/gcc-4.9.4/gcc-4.9.4.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the gcc source";
    rm gcc-4.9.4.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e cloog-0.18.5.tar.gz ] ; then
  echo
  echo "Downloading cloog-0.18.5.tar.gz from cloog-development github site";
  curl -L -O -R https://github.com/periscop/cloog/releases/download/cloog-0.18.5/cloog-0.18.5.tar.gz

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the cloog source";
    rm cloog-0.18.5.tar.gz
    cd ..
    exit 1;
  fi
fi

if [ ! -e isl-0.18.tar.bz2 ] ; then
  echo
  echo "Downloading isl-0.18.tar.bz2 from gnu gcc infrastructure site";
  curl -L -O -R --insecure https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the isl source";
    rm isl-0.18.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e gmp-6.1.2.tar.bz2 ] ; then
  echo
  echo "Downloading gmp-6.1.2.tar.bz2 from ftp.gnu.org mirror site";
  curl -L -O -R http://ftpmirror.gnu.org/gmp/gmp-6.1.2.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the gmp source";
    rm gmp-6.1.2.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e mpfr-3.1.6.tar.bz2 ] ; then
  echo
  echo "Downloading mpfr-3.1.6.tar.bz2 from ftp.gnu.org mirror site";
  curl -L -O -R http://ftpmirror.gnu.org/mpfr/mpfr-3.1.6.tar.bz2

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the mpfr source";
    rm mpfr-3.1.6.tar.bz2
    cd ..
    exit 1;
  fi
fi

if [ ! -e mpc-1.0.3.tar.gz ] ; then
  echo
  echo "Downloading mpc-1.0.2.tar.gz from ftp.gnu.org mirror site";
  curl -L -O -R http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz

  if [ $? != 0 ]; then
    echo "Error: Cannot download the required version of the mpc source";
    rm mpc-1.0.3.tar.gz
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

exit 0
