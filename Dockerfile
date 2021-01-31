FROM golang:buster

COPY package.sh /root/package.sh

RUN apt update && apt install -y \
  cmake \
  ninja-build \
  jq \
  && rm -rf /var/lib/apt/lists/*

RUN curl -SL https://github.com/google/boringssl/archive/master.tar.gz | tar -xzC /root


WORKDIR /root/boringssl-master/build
RUN cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. && ninja

RUN mkdir /root/boringssl-build
RUN mkdir /root/boringssl-build/include
RUN mkdir /root/boringssl-build/lib

RUN cp -r ../include/openssl /root/boringssl-build/include
RUN cp ssl/libssl.a /root/boringssl-build/lib
RUN cp crypto/libcrypto.a /root/boringssl-build/lib

ENTRYPOINT [ "/root/release.sh" ]
