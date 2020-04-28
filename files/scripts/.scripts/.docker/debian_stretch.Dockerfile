# This is used to create an old version of debian with glibc 2.24

FROM debian:stretch

ENV LC_CTYPE C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	 \
	&& apt-get install -y build-essential gcc gcc-multilib python python3 curl make  libc6:i386  tmux bison

COPY bashrc /root/.bashrc
COPY gdbinit /root/.gdbinit
COPY radare2 /root/.config/radare2/
COPY scripts /root/.scripts
COPY tmux.conf /root/.tmux.conf
COPY vim /root/.vim
