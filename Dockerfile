FROM golang:buster

RUN apt-get update && apt-get install -y \
  cmake \
  libbrotli-dev \
  libjemalloc-dev \
  libpcre3-dev \
  ninja-build \
  patch \
  zlib1g-dev \
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

WORKDIR /root
RUN curl -SL https://hg.nginx.org/nginx-quic/archive/tip.tar.gz | tar -xzC /root
RUN find /root -maxdepth 1 -type d -name 'nginx-quic-*' -exec mv {} nginx-quic \;
RUN curl -SL https://github.com/google/ngx_brotli/archive/v1.0.0rc.tar.gz | tar -xzC /root

WORKDIR /root/nginx-quic
RUN curl -SL https://github.com/kn007/patch/raw/master/Enable_BoringSSL_OCSP.patch | patch -p01
RUN ./auto/configure \
  --with-cc-opt='-O2 -fstack-protector-strong -DTCP_FASTOPEN=23 -I../boringssl-build/include' \
  --with-ld-opt='-L../boringssl-build/lib -ljemalloc' \
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-compat \
  --with-file-aio \
  --with-threads \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-http_quic_module \
  --with-stream_quic_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-stream \
  --with-stream_realip_module \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-pcre-jit \
  --with-http_degradation_module \
  --add-module=../ngx_brotli-1.0.0rc
RUN make -j2 && make install

RUN mkdir /root/nginx-build
RUN mkdir -p /root/nginx-build/usr/sbin
RUN mkdir -p /root/nginx-build/etc

RUN cp /usr/sbin/nginx /root/nginx-build/usr/sbin
RUN cp -r /etc/nginx /root/nginx-build/etc

COPY upload.sh /root/upload.sh

ENTRYPOINT [ "/root/upload.sh" ]
