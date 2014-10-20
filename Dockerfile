FROM shimaore/debian
MAINTAINER Stéphane Alnet <stephane@shimaore.net>

# Install prereqs
RUN apt-get update && apt-get --no-install-recommends -y install \
  build-essential \
  ca-certificates \
  git
RUN apt-get --no-install-recommends -y install \
  libssl-dev \
  libsctp-dev \
  bison \
  flex \
  libncurses5-dev m4

RUN useradd -m opensips
USER opensips
WORKDIR /home/opensips
RUN git clone http://stephane.shimaore.net/debian/src/opensips.git -b 1.11 opensips.git

# Build
WORKDIR opensips.git
RUN make TLS=1 SCTP=1
RUN make modules

# Install
USER root
RUN make install

# Cleanup
RUN apt-get purge -y \
  build-essential \
  git
USER opensips
WORKDIR /home/opensips
RUN rm -rf opensips.git
