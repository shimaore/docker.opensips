FROM debian:testing-slim
MAINTAINER Stéphane Alnet <stephane@shimaore.net>

# Install prereqs
RUN apt-get update && apt-get --no-install-recommends -y install \
  bison \
  build-essential \
  ca-certificates \
  flex \
  git \
  libcurl4-gnutls-dev \
  libjson-c-dev \
  libhiredis-dev \
  libmicrohttpd-dev \
  libncurses5-dev \
  libsctp-dev \
  libssl-dev \
  libxml2-dev \
  m4 \
  netbase \
  pkg-config \
  && \
  useradd -m opensips && \
  mkdir -p /opt/opensips && \
  chown -R opensips.opensips /opt/opensips

USER opensips
WORKDIR /home/opensips
RUN \
  git clone -b 2.2 https://github.com/OpenSIPS/opensips.git opensips.git && \
  cd opensips.git && \
  git checkout 23a905773e9e5fcad095207ab7ee036896ec857c && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic cachedb_redis db_http httpd json rest_client presence presence_mwi presence_dialoginfo pua pua_dialoginfo" && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic cachedb_redis db_http httpd json rest_client presence presence_mwi presence_dialoginfo pua pua_dialoginfo" modules && \
  make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic cachedb_redis db_http httpd json rest_client presence presence_mwi presence_dialoginfo pua pua_dialoginfo" install && \
  cd .. && \
  rm -rf opensips.git

# Cleanup
USER root
RUN apt-get purge -y \
  bison \
  build-essential \
  ca-certificates \
  cpp-6 \
  flex \
  gcc-6 \
  git \
  m4 \
  pkg-config \
  && apt-get autoremove -y && \
  apt-get install -y \
  libmicrohttpd12 \
  && apt-get clean
USER opensips
WORKDIR /home/opensips
