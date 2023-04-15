#!/usr/bin/env bash

set -e

# Root cb-multios directory
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SYMCC_BIN="/cb-multios/symcc/build" # symcc,sym++
SYMCC_HELPER="/root/.cargo/bin/symcc_fuzzing_helper"

if [[ -z "${NO_PYTHON_I_KNOW_WHAT_I_AM_DOING_I_SWEAR}" ]]; then
  # Install necessary python packages
  if ! /usr/bin/env python2 -c "import xlsxwriter; import Crypto" 2>/dev/null; then
      echo "Please install required python packages" >&2
      echo "  $ sudo pip install xlsxwriter pycrypto" >&2
      exit 1
  fi
fi

function symcc {
  cd ${DIR}

  cd symcc
  mkdir build
  cd build

  CC=clang-14
  CXX=clang++-14
  CMAKE_OPTS="-DCMAKE_C_COMPILER=${CC} -DCMAKE_ASM_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"
  cmake -DQSYM_BACKEND=ON -DZ3_TRUST_SYSTEM_VERSION=ON ${CMAKE_OPTS} ..
  make #-j$(nproc)

  cd .. # /cb-multios/symcc
  cargo install --path util/symcc_fuzzing_helper

  unset CC
  unset CXX
  unset CMAKE_OPTS
}

function build {
#  cd ${DIR} - DONT DO THIS! We want to be in a build folder from before being invoked :)

  echo "Creating Makefiles"
  CMAKE_OPTS="-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

  CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_C_COMPILER=$CC"
  CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_ASM_COMPILER=$CC"
  CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_CXX_COMPILER=$CXX"

  LINK=${LINK:-SHARED}
  case $LINK in
      SHARED) CMAKE_OPTS="$CMAKE_OPTS -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF";;
      STATIC) CMAKE_OPTS="$CMAKE_OPTS -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON";;
  esac

  BITNESS=${BITNESS:-32}
  case $BITNESS in
      32) CMAKE_OPTS="$CMAKE_OPTS -DBUILD_32BIT=ON";;
      64) CMAKE_OPTS="$CMAKE_OPTS -DBUILD_32BIT=OFF";;
  esac

  # Prefer ninja over make, if it is available
  if command -v ninja >/dev/null; then
    CMAKE_OPTS="-G Ninja $CMAKE_OPTS"
  fi

  cmake -DCMAKE_C_FLAGS="-fcommon" -DCMAKE_CXX_FLAGS="-fcommon" $CMAKE_OPTS ..

  cmake --build .

  unset CMAKE_OPTS
}

function build_regular {
  echo "Creating build directory"
  mkdir -p "${DIR}/build"
  cd "${DIR}/build"

  CC=clang-14
  CXX=clang++-14

  build

  unset CC
  unset CXX
}

function build_afl {
  echo "Creating build_afl directory"
  mkdir -p "${DIR}/build_afl"
  cd "${DIR}/build_afl"

  export AFL_USE_ASAN=1

  # We need to compile with afl-clang :)
  CC=afl-clang
  CXX=afl-clang++

  build

  unset CC
  unset CXX
}

function build_symcc {
  echo "Creating build_symcc directory"
  mkdir -p "${DIR}/build_symcc"
  cd "${DIR}/build_symcc"

  export SYMCC_REGULAR_LIBCXX=true

  CC=${SYMCC_BIN}/symcc
  CXX=${SYMCC_BIN}/sym++

  build

  export -n SYMCC_REGULAR_LIBCXX
  unset CC
  unset CXX
}

symcc

build_regular
build_symcc
build_afl
