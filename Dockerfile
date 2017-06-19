## Dockerfile for a haskell environment
FROM       debian:jessie
MAINTAINER Felix Eckhardt <felix.eckhardt@ambiata.com>

ENV LANG            en.UTF-8
ENV HOME            /home

ARG HOME=/home
ARG CABAL_VERSION=1.24.0.0
ARG GHCI_VERSION=7.10.2
ARG NODEJS_VERSION=6.11.0

ENV PATH="${PATH}:${HOME}/cabal/bin:${HOME}/haskell/${GHCI_VERSION}/bin"

RUN apt-get update && apt-get install -y \
  build-essential \
  ca-certificates \
  libgmp10 \
  libgmp-dev \
  libffi-dev \
  zlib1g-dev \
  libtinfo-dev \
  gcc \
  git \
  wget \
  curl \
  python

# install ghci
RUN mkdir -p ~/ghci && \
  cd ~/ghci && \
  wget -nv https://downloads.haskell.org/~ghc/${GHCI_VERSION}/ghc-${GHCI_VERSION}-x86_64-unknown-linux-deb7.tar.xz && \
  echo "tar xf ghc-${GHCI_VERSION}-x86_64-unknown-linux-deb7.tar.xz" && \
  tar xvJf ghc-${GHCI_VERSION}-x86_64-unknown-linux-deb7.tar.xz && \
  cd ghc-${GHCI_VERSION} && \
  ./configure --prefix=$HOME/haskell/${GHCI_VERSION} && \
  make install

# install cabal
RUN \
  mkdir -p $HOME/cabal && \
  cd $HOME/cabal && \
  wget -nv "http://hackage.haskell.org/package/cabal-install-${CABAL_VERSION}/cabal-install-${CABAL_VERSION}.tar.gz" && \
  tar xzf cabal-install-${CABAL_VERSION}.tar.gz && \
  cd cabal-install-${CABAL_VERSION} && \
  EXTRA_CONFIGURE_OPTS="" ./bootstrap.sh --sandbox --no-doc && \
  mkdir -p ~/cabal/bin && \
  cp .cabal-sandbox/bin/cabal $HOME/cabal/bin

# install libsass, see http://crocodillon.com/blog/how-to-install-sassc-and-libsass-on-ubuntu
RUN \
  cd /usr/local/lib/ && \
  git clone https://github.com/sass/sassc.git --branch 3.4.2 --depth 1 && \
  git clone https://github.com/sass/libsass.git --branch 3.4-stable --depth 1 && \
  git clone https://github.com/sass/sass-spec.git --depth=1 && \
  export SASS_LIBSASS_PATH="/usr/local/lib/libsass" && \
  make -C libsass && \
  make -C sassc && \
  make -C sassc install

# build nodejs
RUN \
  cd /tmp && \
  wget https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}.tar.gz && \
  tar xzvf node-v${NODEJS_VERSION}.tar.gz && \
  cd node-v${NODEJS_VERSION} && \
  ./configure && \
  make && \
  make install && \
  cd /tmp && rm -R node-v${NODEJS_VERSION}

