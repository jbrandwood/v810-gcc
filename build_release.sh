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
target="v810"

binutils_ver="2.27"
gcc_ver="4.9.4"
newlib_ver="2.2.0-1"
cloog_ver="0.18.5"
isl_ver="0.18"
gmp_ver="6.1.2"
mpfr_ver="3.1.6"
mpc_ver="1.0.3"


os=$(uname -s)

dstdir=${PWD}/${target}-gcc
mkdir -p "${dstdir}"/{bin,lib}

export PATH=${dstdir}/bin:$PATH

rm -rf src build

# Set the target compiler flags
#------------------------------------------------------------------------------
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS=""

case $os in
    Linux)
      os_name="Linux"
      cpus=$(nproc)
      build="--build=x86_64-linux-gnu"
      ;;
    Darwin)
      os_name="macOS"
      cpus=$(sysctl -n hw.logicalcpu)
      build="--build=x86_64-apple-darwin20"
      ;;
    Windows_NT|MINGW64_NT*)
      os_name="Windows"
      cpus=$(nproc)
      build=""
      export CFLAGS="-O2 -static"
      export CXXFLAGS="-O2 -static"
      export LDFLAGS="-Wl,-Bstatic"
    # export LDFLAGS="-Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive"
      ;;
    *)
        echo "Unknown OS: $os"
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
    [binutils]="http://ftpmirror.gnu.org/binutils/binutils-${binutils_ver}.tar.bz2"
    [gcc]="http://ftpmirror.gnu.org/gcc/gcc-${gcc_ver}/gcc-${gcc_ver}.tar.bz2"
    [newlib]="ftp://sourceware.org/pub/newlib/newlib-${newlib_ver}.tar.gz"
    [cloog]="https://github.com/periscop/cloog/releases/download/cloog-${cloog_ver}/cloog-${cloog_ver}.tar.gz"
    [isl]="https://gcc.gnu.org/pub/gcc/infrastructure/isl-${isl_ver}.tar.bz2"
    [gmp]="http://ftpmirror.gnu.org/gmp/gmp-${gmp_ver}.tar.bz2"
    [mpfr]="http://ftpmirror.gnu.org/mpfr/mpfr-${mpfr_ver}.tar.bz2"
    [mpc]="http://ftpmirror.gnu.org/mpc/mpc-${mpc_ver}.tar.gz"
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
for file in "patch/binutils-${binutils_ver}"*; do
    echo "### Patching binutils with $file"
    patch -d src/binutils -p 1 -i "../../$file"
done

for file in "patch/gcc-${gcc_ver}"*; do
    echo "### Patching GCC with $file"
    patch -d src/gcc -p 1 -i "../../$file"
done

for file in "patch/newlib-${newlib_ver}"*; do
    echo "### Patching newlib with $file"
    patch -d src/newlib -p 1 -i "../../$file"
done

# Build and install programs
#------------------------------------------------------------------------------
echo "### BINUTILS ###########################################################"
[[ -d build/binutils ]] || mkdir -p build/binutils
cd build/binutils
../../src/binutils/configure \
    "$build" \
    --target="$target" \
    --prefix="$dstdir" \
    --with-lib-path="${dstdir}/lib" \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-lto
make --jobs="$cpus" all
make install-strip
cd -
rm -f "${dstdir}/bin/$target-ld.bfd" "${dstdir}/${target}/bin/ld.bfd"

echo "### GCC (initial) ######################################################"
[[ -d build/gcc ]] || mkdir -p build/gcc
cd build/gcc
../../src/gcc/configure \
    "$build" \
    --target="$target" \
    --prefix="$dstdir" \
    --without-headers \
    --with-newlib \
    --with-local-prefix="$dstdir" \
    --with-native-system-header="${dstdir}/include" \
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
make --jobs="$cpus" all
make install-strip
cd -
rm -f "${dstdir}/bin/${target}-gcc-"{4.9.4,ar,nm,ranlib}

echo "### NEWLIB #############################################################"
[[ -d build/newlib ]] || mkdir -p build/newlib
cd build/newlib
../../src/newlib/configure \
    $build \
    --target="$target" \
    --prefix="$dstdir" \
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
make --jobs="$cpus" all
make install
cd -

echo "### GCC (final) ########################################################"
[[ -d build/gcc ]] || mkdir -p build/gcc
cd build/gcc
../../src/gcc/configure \
    $build \
    --target="$target" \
    --prefix="$dstdir" \
    --with-local-prefix="$dstdir" \
    --with-native-system-header="${dstdir}/include" \
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
make --jobs="$cpus" all
make install-strip
cd -
rm -f "${dstdir}/bin/${target}-gcc-"{4.9.4,ar,nm,ranlib}

# Make artifact
zip -r "${target}-gcc-${os_name}-x86_64.zip" "${target}-gcc"
