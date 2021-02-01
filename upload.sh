#!/bin/bash

API_USER=$1
API_KEY=$2

if [ -z $API_USER ] || [ -z $API_KEY ]; then
  exit 1
fi

echo -e "machine api.bintray.com\n  login $1\n  password $2" > /root/.netrc

now=$(TZ='Asia/Shanghai' date "+%Y%m%d")

upload_to_bintray() {
  curl -n \
    -X PUT \
    -H "X-Bintray-Package: buster" \
    -H "X-Bintray-Version: $now" \
    -H "X-Bintray-Publish: 1" \
    -H "X-Bintray-Override: 1" \
    https://api.bintray.com/content/hguandl/debian-packages/buster/$1 \
    --data-binary @$1
}

tar -czf /root/boringssl-build-buster-$now.tar.gz -C /root boringssl-build
tar -czf /root/nginx-build-buster-$now.tar.gz -C /root nginx-build

cd /root
upload_to_bintray boringssl-build-buster-$now.tar.gz
upload_to_bintray nginx-build-buster-$now.tar.gz

exit
