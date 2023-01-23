#! /bin/sh
#
# Build script for V810-GCC.
#
# Stage 8 of 8 - Build the final version of GCC now that NEWLIB exists.
#
# If this stage fails, then you can find out what the error was, fix it, and
# re-run this script without running prepare_gcc2.sh again.
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
# Build a minimal GCC
#---------------------------------------------------------------------------------

cd $GITDIR/build/gcc

make --jobs=$(nproc) all 2>&1 | tee gcc_make.log

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

rm $DSTDIR/bin/$TARGET-gcc-4.9.4*
rm $DSTDIR/bin/$TARGET-gcc-ar*
rm $DSTDIR/bin/$TARGET-gcc-nm*
rm $DSTDIR/bin/$TARGET-gcc-ranlib*

echo
echo "$0 finished, don't forget to check for any error messages."

exit 0
