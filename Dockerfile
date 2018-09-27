FROM alpine:edge
MAINTAINER Stéphane Alnet <stephane@shimaore.net>

RUN \
  addgroup -S opensips && \
  adduser -S -D -s /sbin/nologin -G opensips -g OpenSIPS opensips && \
  mkdir -p /opt/opensips && \
  chown -R opensips.opensips /opt/opensips \

COPY tos.patch /tmp/tos.patch
COPY musl-libc.patch /tmp/musl-libc.patch

# Install prereqs
ENV MODULES \
  b2b_logic \
  cachedb_redis \
  db_http \
  httpd \
  json \
  rest_client \
  presence \
  presence_mwi \
  presence_dialoginfo \
  proto_tls \
  proto_wss \
  pua \
  pua_dialoginfo \
  tls_mgm

RUN apk add --update --no-cache \
  json-c \
  hiredis \
  ncurses \
  lksctp-tools \
  libssl1.0 \
  libxml2 \
  libmicrohttpd \
  \
  && \
  apk add --update --no-cache --virtual .build-deps \
  bison \
  build-base \
  ca-certificates \
  flex \
  git \
  m4 \
  curl-dev \
  gnutls-dev \
  json-c-dev \
  hiredis-dev \
  ncurses-dev \
  libmicrohttpd-dev \
  lksctp-tools-dev \
  libxml2-dev \
  patch \
  linux-headers \
  pkgconf \
  && \
  cd /home/opensips \
  && \
  git clone -b 2.4 https://github.com/OpenSIPS/opensips.git opensips.git && \
  cd opensips.git && \
  git checkout cb43020ee61614dbd2a4bd5009874365b1f98f56 && \
  patch < /tmp/tos.patch && \
  patch -p1 < /tmp/musl-libc.patch && rm -f /tmp/musl-libc.patch && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="${MODULES}" && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="${MODULES}" modules && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="${MODULES}" install && \
  cd .. && \
  rm -rf opensips.git \
  && \
  apk del .build-deps \
  && rm -rf \
    /opt/opensips/etc/opensips/opensips.cfg \
    /opt/opensips/etc/opensips/tls/ \
  && chown opensips /opt/opensips/etc/opensips/ \
  && echo Done
USER opensips
WORKDIR /home/opensips
