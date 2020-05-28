# This is used to create an old version of debian with glibc 2.24

FROM debian:stretch

ENV LC_CTYPE C.UTF-8

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y bison build-essential curl gcc gcc-multilib \
		libc6:i386 make python python3 tmux
