FROM ubuntu:16.04

MAINTAINER gchevalley <gregory.chevalley@gmail.com>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y \
  apache2-utils \
  apt-transport-https \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  g++ \
  git \
  libssl-dev \
  libxml2-dev \
  make \
  python \
  python-software-properties \
  rsync \
  software-properties-common \
  sshfs \
  supervisor \
  wget


# https://stackoverflow.com/questions/25899912/install-nvm-in-docker
ENV NVM_VERSION v0.33.6
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.11.5

RUN curl https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN git clone https://github.com/c9/core.git /c9sdk
WORKDIR /c9sdk

RUN scripts/install-sdk.sh
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /c9sdk/configs/standalone.js 

# https://github.com/kdelfour/supervisor-docker
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD cloud9.conf /etc/supervisor/conf.d/
RUN update-rc.d supervisor defaults

RUN mkdir /workspace
VOLUME /workspace

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80 3000 8181

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
