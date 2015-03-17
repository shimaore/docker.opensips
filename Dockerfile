FROM shimaore/debian
MAINTAINER Stéphane Alnet <stephane@shimaore.net>

# Install prereqs
RUN apt-get update && apt-get --no-install-recommends -y install \
  bison \
  build-essential \
  ca-certificates \
  flex \
  git \
  libcurl4-gnutls-dev \
  libjson0-dev \
  libmicrohttpd-dev \
  libncurses5-dev \
  libsctp-dev \
  libssl-dev \
  libxml2-dev \
  m4 \
  netbase \
  pkg-config

RUN useradd -m opensips
USER opensips
WORKDIR /home/opensips
RUN git clone https://github.com/OpenSIPS/opensips.git -b 1.11 opensips.git

# Build
WORKDIR opensips.git
RUN make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic db_http httpd json rest_client"
RUN make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic db_http httpd json rest_client" modules

# Install
USER root
RUN mkdir -p /opt/opensips
RUN chown -R opensips.opensips /opt/opensips
USER opensips
RUN make TLS=1 SCTP=1 prefix=/opt/opensips include_modules="b2b_logic db_http httpd json rest_client" install

# Cleanup
USER root
RUN apt-get purge -y \
  bison \
  build-essential \
  flex \
  git \
  m4
USER opensips
WORKDIR /home/opensips
RUN rm -rf opensips.git
