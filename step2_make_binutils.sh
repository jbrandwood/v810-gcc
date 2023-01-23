#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 2 of 8 - Build BINUTILS.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_binutils.sh again.
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
# Set the target and compiler flags
#---------------------------------------------------------------------------------

if [ "$OS" = "Windows_NT" ] ; then
  export CFLAGS='-O2 -static'
  export CXXFLAGS='-O2 -static'
  export LDFLAGS='-Wl,-Bstatic'
# export LDFLAGS='-Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive'
else
  export CFLAGS='-O2'
  export CXXFLAGS='-O2'
  export LDFLAGS=
fi

#---------------------------------------------------------------------------------
# Build and install binutils
#---------------------------------------------------------------------------------

cd $GITDIR/build/binutils

make --jobs=$(nproc) all 2>&1 | tee binutils_make.log

if [ $? != 0 ]; then
  echo "Error: building binutils";
  exit 1;
fi

# !It would be nice if this worked!
#
# make check-gas 2>&1 | tee binutils_test.log
#
# if [ $? != 0 ]; then
#   echo "Error: testing binutils";
#   exit 1;
# fi

# make tooldir=$DSTDIR install-strip 2>&1 | tee binutils_install.log

make install-strip 2>&1 | tee binutils_install.log

if [ $? != 0 ]; then
  echo "Error: installing binutils";
  exit 1;
fi

cd ../../

#---------------------------------------------------------------------------------
# Remove duplicate/unnecessary files to save space
#---------------------------------------------------------------------------------

rm $DSTDIR/bin/$TARGET-ld.bfd*
rm $DSTDIR/$TARGET/bin/ld.bfd*

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0;
