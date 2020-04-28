# Lite docker container

FROM ubuntu:19.10

ENV LC_CTYPE C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y vim gcc gdb

COPY bashrc /root/.bashrc
COPY gdbinit /root/.gdbinit
COPY radare2 /root/.config/radare2/
COPY scripts /root/.scripts
COPY tmux.conf /root/.tmux.conf
COPY vim /root/.vim
