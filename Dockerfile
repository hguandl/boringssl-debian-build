FROM debian:buster

RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  build-essential \
  checkinstall/buster-backports \
  cmake \
  curl \
  git \
  gcc \
  g++ \
  golang \
  libbrotli-dev \
  libjemalloc-dev \
  libpcre3-dev \
  ninja-build \
  patch \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

COPY . /root/nginx-quic-debian-build
WORKDIR /root/nginx-quic-debian-build

ENTRYPOINT [ "/root/nginx-quic-debian-build/main.sh" ]
