#!/bin/bash

# $1: API_USER
# $2: API_KEY
setup_keys() {
  if [ -z $1 ] || [ -z $2 ]; then
    exit 1
  fi

  echo -e "machine api.bintray.com\n  login $1\n  password $2" > /root/.netrc
}

upload_to_bintray() {
  curl -n -fsSL \
    -X PUT \
    -H "X-Bintray-Package: buster" \
    -H "X-Bintray-Version: $TODAY" \
    -H "X-Bintray-Publish: 1" \
    -H "X-Bintray-Override: 1" \
    https://api.bintray.com/content/hguandl/debian-packages/buster/$1 \
    --data-binary @$1
}
