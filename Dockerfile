FROM shimaore/debian
MAINTAINER Stéphane Alnet <stephane@shimaore.net>

# Install prereqs
RUN apt-get update && apt-get --no-install-recommends -y install \
  bison \
  build-essential \
  ca-certificates \
  flex \
  git \
  libncurses5-dev \
  libsctp-dev \
  libssl-dev \
  m4

RUN useradd -m opensips
USER opensips
WORKDIR /home/opensips
RUN git clone https://github.com/OpenSIPS/opensips.git -b 1.11 opensips.git

# Build
WORKDIR opensips.git
# FIXME Set instal dir to /opt/opensips
RUN make TLS=1 SCTP=1 prefix=/opt/opensips
RUN make modules TLS=1 SCTP=1 prefix=/opt/opensips

# Install
USER root
RUN mkdir -p /opt/opensips
RUN chown -R opensips.opensips /opt/opensips
USER opensips
RUN make install TLS=1 SCTP=1 prefix=/opt/opensips

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
