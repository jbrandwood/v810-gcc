#!/usr/bin/env bash
#
# Build script for Github Actions
#

set -euo pipefail

if [[ -z ${CI-} ]]; then
    echo "This script is intended to be run via Github Actions"
    exit 1
fi

# =============================================================================
# Environment setup
# =============================================================================
TARGET="v810"

BINUTILS_VER="2.27"
GCC_VER="4.9.4"
NEWLIB_VER="2.2.0-1"
CLOOG_VER="0.18.5"
ISL_VER="0.18"
GMP_VER="6.1.2"
MPFR_VER="3.1.6"
MPC_VER="1.0.3"


OS=$(uname -s)

DSTDIR=${PWD}/${TARGET}-gcc
mkdir -p "${DSTDIR}"/{bin,lib}

export PATH=${DSTDIR}/bin:$PATH

rm -rf src build

# Set the target compiler flags
#------------------------------------------------------------------------------
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS=""

case $OS in
    Linux)
      CPUS=$(nproc)
      BUILD="--build=x86_64-linux-gnu"
      ;;
    Darwin)
      CPUS=$(sysctl -n hw.logicalcpu)
      BUILD="--build=x86_64-apple-darwin20"
      ;;
    Windows_NT|MINGW64_NT*)
      CPUS=$(nproc)
      BUILD=""
      export CFLAGS="-O2 -static"
      export CXXFLAGS="-O2 -static"
      export LDFLAGS="-Wl,-Bstatic"
    # export LDFLAGS="-Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive"
      ;;
    *)
        echo "Unknown OS: $OS"
        exit 1
esac

# =============================================================================
# Check Prerequisites
# =============================================================================
prereqs=(
    curl
    make
    makeinfo
    gcc
    flex
    patch
    tar
    gzip
    autoconf
    gperf
    bison
)

echo "Ensuring prerequisite programs are available"
for i in "${prereqs[@]}"; do
    type "$i"
done

# =============================================================================
# Download tarballs and extract to the build directory
# =============================================================================
declare -A sources
sources=(
    [binutils]="http://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VER}.tar.bz2"
    [gcc]="http://ftpmirror.gnu.org/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.bz2"
    [newlib]="ftp://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz"
    [cloog]="https://github.com/periscop/cloog/releases/download/cloog-${CLOOG_VER}/cloog-${CLOOG_VER}.tar.gz"
    [isl]="https://gcc.gnu.org/pub/gcc/infrastructure/isl-${ISL_VER}.tar.bz2"
    [gmp]="http://ftpmirror.gnu.org/gmp/gmp-${GMP_VER}.tar.bz2"
    [mpfr]="http://ftpmirror.gnu.org/mpfr/mpfr-${MPFR_VER}.tar.bz2"
    [mpc]="http://ftpmirror.gnu.org/mpc/mpc-${MPC_VER}.tar.gz"
)

[[ -d archive ]] || mkdir archive

for i in "${!sources[@]}"; do
    name=$i
    url=${sources[$i]}
    file=${sources[$i]##*/}


    if [[ ! -f archive/$file ]]; then
        echo "Downloading $file"
        curl -LOR --output-dir archive "$url"
    fi

    case $name in
        binutils) dest=src/binutils ;;
        gcc)      dest=src/gcc ;;
        newlib)   dest=src/newlib ;;
        *)        dest=src/gcc/$name ;;
    esac

    echo "Extracting $file to $dest"
    mkdir -p "$dest"
    tar xf "archive/$file" -C "$dest" --strip-components=1
done

# =============================================================================
# Apply patches
# =============================================================================
for file in "patch/binutils-${BINUTILS_VER}"*; do
    echo "### Patching binutils with $file"
    patch -d src/binutils -p 1 -i "../../$file"
done

for file in "patch/gcc-${GCC_VER}"*; do
    echo "### Patching GCC with $file"
    patch -d src/gcc -p 1 -i "../../$file"
done

for file in "patch/newlib-${NEWLIB_VER}"*; do
    echo "### Patching newlib with $file"
    patch -d src/newlib -p 1 -i "../../$file"
done

# Build and install programs
#------------------------------------------------------------------------------
echo "### BINUTILS ###########################################################"
[[ -d build/binutils ]] || mkdir -p build/binutils
cd build/binutils
../../src/binutils/configure \
    "$BUILD" \
    --target="$TARGET" \
    --prefix="$DSTDIR" \
    --with-lib-path="${DSTDIR}/lib" \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-lto
make --jobs="$CPUS" all
make install-strip
cd -
rm -f "$DSTDIR/bin/$TARGET-ld.bfd" "$DSTDIR/$TARGET/bin/ld.bfd"

echo "### GCC (initial) ######################################################"
[[ -d build/gcc ]] || mkdir -p build/gcc
cd build/gcc
../../src/gcc/configure \
  "$BUILD" \
  --target="$TARGET" \
  --prefix="$DSTDIR" \
  --without-headers \
  --with-newlib \
  --with-local-prefix="$DSTDIR" \
  --with-native-system-header="${DSTDIR}/include" \
  --disable-shared \
  --enable-static \
  --disable-pedantic \
  --disable-nls \
  --disable-multilib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libitm \
  --disable-libssp \
  --disable-libstdc++-v3 \
  --disable-libquadmath \
  --disable-lto \
  --enable-frame-pointer \
  --enable-languages=c
make --jobs="$CPUS" all
make install-strip
cd -
rm -f "$DSTDIR/bin/$TARGET-gcc-"{4.9.4,ar,nm,ranlib}

echo "### NEWLIB #############################################################"
[[ -d build/newlib ]] || mkdir -p build/newlib
cd build/newlib
../../src/newlib/configure \
  $BUILD \
  --target="$TARGET" \
  --prefix="$DSTDIR" \
  --disable-multilib \
  --disable-newlib-multithread \
  --disable-newlib-iconv \
  --disable-newlib-fvwrite-in-streamio \
  --disable-newlib-fseek-optimization \
  --disable-newlib-wide-orient \
  --disable-newlib-io-float \
  --disable-newlib-atexit-dynamic-alloc \
  --disable-newlib-supplied-syscalls \
  --enable-newlib-global-atexit \
  --enable-newlib-nano-formatted-io \
  --enable-newlib-nano-malloc \
  --enable-newlib-reent-small \
  --enable-lite-exit \
  --enable-newlib-hw-fp
make --jobs="$CPUS" all
make install
cd -

echo "### GCC (final) ########################################################"
[[ -d build/gcc ]] || mkdir -p build/gcc
cd build/gcc
../../src/gcc/configure \
  $BUILD \
  --target="$TARGET" \
  --prefix="$DSTDIR" \
  --with-local-prefix="$DSTDIR" \
  --with-native-system-header="${DSTDIR}/include" \
  --disable-shared \
  --enable-static \
  --disable-pedantic \
  --disable-nls \
  --disable-multilib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libitm \
  --disable-libssp \
  --disable-libstdc++-v3 \
  --disable-libquadmath \
  --disable-lto \
  --enable-frame-pointer \
  --enable-languages=c,c++
make --jobs="$CPUS" all
make install-strip
cd -
rm -f "${DSTDIR}/bin/${TARGET}-gcc-"{4.9.4,ar,nm,ranlib}
