# Copy/paste from:
#     https://hub.docker.com/r/angr/angr/dockerfile

FROM ubuntu:focal
MAINTAINER yans@yancomm.net

ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386
RUN apt-get update

RUN apt-get install -y binutils-multiarch build-essential cmake
RUN apt-get install -y debian-archive-keyring debootstrap git libc6:i386
RUN apt-get install -y libffi-dev libgcc1:i386 libglib2.0-dev libpixman-1-dev
RUN apt-get install -y libreadline-dev libssl-dev libstdc++6:i386
RUN apt-get install -y libtinfo5:i386 libtool libxml2-dev libxslt1-dev nasm
RUN apt-get install -y openjdk-8-jdk python3-dev python3-pip qtdeclarative5-dev
RUN apt-get install -y vim virtualenvwrapper zlib1g:i386

RUN useradd -s /bin/bash -m angr

RUN su - angr -c "git clone https://github.com/angr/angr-dev && cd angr-dev && ./setup.sh -w -e angr && ./setup.sh -w -p angr-pypy"
RUN su - angr -c "echo 'source /usr/share/virtualenvwrapper/virtualenvwrapper.sh' >> /home/angr/.bashrc && echo 'workon angr' >> /home/angr/.bashrc"
CMD su - angr
