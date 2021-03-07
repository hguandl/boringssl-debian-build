#!/bin/bash

# $1: src base directory
get_boringssl_src() {
  curl -fsSL https://github.com/google/boringssl/archive/master.tar.gz | tar -xzC "$1"
  mkdir -p "$1"/boringssl-master/build
}

# $1: src base directory
build_boringssl() {
  pushd "$1"/boringssl-master/build

  cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. && ninja

  popd
}

# $1: src base directory
# $2: install prefix
install_boringssl() {
  pushd "$1"/boringssl-master/build

  mkdir -p "$2"/include
  mkdir -p "$2"/lib

  cp -r ../include/openssl "$2"/include/
  cp ssl/libssl.a "$2"/lib/
  cp crypto/libcrypto.a "$2"/lib/

  popd
}
