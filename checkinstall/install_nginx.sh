#!/bin/bash

make -C "$1" install

cp nginx.logrotate /etc/logrotate.d/nginx-quic
cp nginx-quic.service /lib/systemd/system/nginx-quic.service
