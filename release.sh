#!/bin/sh

API_USER=$1
API_KEY=$2

if [ -z $API_USER ] || [ -z $API_KEY ]; then
  exit 1
fi

echo -e "machine github.com\n  login $1\n  password $2" > /root/.netrc

now=$(TZ='Asia/Shanghai' date "+%Y%m%d")

tar -czf /root/boringssl-build-buster-$now.tar.gz -C /root boringssl-build

rid=$(\
curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/hguandl/boringssl-debian-build/releases \
  -d '{"tag_name":"'$now'"}' | \
jq '.id'\
)

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/hguandl/boringssl-debian-build/releases/$rid/assets \
  --upload-file /root/boringssl-build-buster-$now.tar.gz

exit
