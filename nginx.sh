#!/bin/bash

# $1: src base directory
get_nginx_src() {
  curl -fsSL https://hg.nginx.org/nginx-quic/archive/tip.tar.gz | tar -xzC "$1"
  NGINX_BUILD=$(find "$1" -maxdepth 1 -type d -name 'nginx-quic-*' | cut -d - -f 3)
  curl -fsSL https://github.com/google/ngx_brotli/archive/v1.0.0rc.tar.gz | tar -xzC "$1"
  curl -fsSL https://github.com/kn007/patch/raw/master/Enable_BoringSSL_OCSP.patch -o "$1"/Enable_BoringSSL_OCSP.patch
}

# $1: src base directory
build_nginx() {
  pushd "$1"/nginx-quic-$NGINX_BUILD

  patch -p01 -i "$1"/Enable_BoringSSL_OCSP.patch

  ./auto/configure \
    --with-cc-opt='-O2 -fstack-protector-strong -DTCP_FASTOPEN=23 -I../boringssl/include' \
    --with-ld-opt='-L../boringssl/lib -ljemalloc' \
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

  make -j2

  popd
}

# $1: src base directory
# $2: package saving directory
install_nginx() {
  pushd $CTRL_BASE/checkinstall

  checkinstall --nodoc --install=no -y \
  --pakdir="$2" \
  --maintainer=hguandl@gmail.com \
  --pkgname=nginx-quic \
  --pkgversion=$TODAY \
  --pkgrelease=$NGINX_BUILD \
  --pkglicense=BSD \
  --pkggroup=checkinstall \
  --requires="libbrotli1, libjemalloc2, libpcre3, zlib1g" \
  --conflicts="nginx-common, nginx-core, nginx" \
  --replaces="nginx-common, nginx-core, nginx" \
  make -C "$1"/nginx-quic-$NGINX_BUILD install

  popd
}
