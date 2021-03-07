#!/bin/bash

# $1: filename
# $2: API_USER
# $3: API_KEY
upload_to_bintray() {
  curl -fsSL \
    -u "$2:$3" \
    -X PUT \
    -H "X-Bintray-Package: buster" \
    -H "X-Bintray-Version: $TODAY" \
    -H "X-Bintray-Publish: 1" \
    -H "X-Bintray-Override: 1" \
    https://api.bintray.com/content/hguandl/debian-packages/buster/$1 \
    --data-binary @$1
}
