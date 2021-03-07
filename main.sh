#!/bin/bash

CTRL_BASE="/root/nginx-quic-debian-build"
TODAY=$(TZ='Asia/Shanghai' date "+%Y%m%d")

source boringssl.sh
source nginx.sh
source upload.sh

case $1 in

  "build")
    get_boringssl_src "/opt"
    build_boringssl "/opt"
    install_boringssl "/opt" "/opt/boringssl"

    get_nginx_src "/opt"
    build_nginx "/opt"
    install_nginx "/opt" "/root"
    ;;

  "upload")
    setup_keys $2 $3
    pushd /root
    filename=$(ls -1 *.deb)
    upload_to_bintray $filename
    popd
    ;;

  *)
    exit
    ;;
esac
