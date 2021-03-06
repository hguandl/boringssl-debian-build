#!/bin/bash

CTRL_BASE="/root/nginx-quic-debian-build"
TODAY=$(TZ='Asia/Shanghai' date "+%Y%m%d")

source $CTRL_BASE/boringssl.sh
source $CTRL_BASE/nginx.sh
source $CTRL_BASE/upload.sh

build_only() {
  get_boringssl_src "/opt"
  build_boringssl "/opt"
  install_boringssl "/opt" "/opt/boringssl"

  get_nginx_src "/opt"
  build_nginx "/opt"
  install_nginx "/opt" "/root"
}

upload_only() {
  pushd /root
  filename=$(ls -1 *.deb)
  upload_to_bintray $filename $1 $2
  popd
}

case $1 in
  "build")
    build_only
    ;;

  "upload")
    upload_only $2 $3
    ;;

  "deploy")
    build_only
    upload_only $2 $3
    ;;

  *)
    ;;
esac
