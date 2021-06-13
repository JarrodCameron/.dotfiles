# This is the generic docker file, uses the most up to date version of ubuntu

FROM ubuntu

ENV LC_CTYPE C.UTF-8

RUN dpkg --add-architecture i386

RUN apt-get update
RUN apt-get update --fix-missing

# Set timezone for php
RUN ln -snf /usr/share/zoneinfo/'Australia/Sydney' /etc/localtime
RUN echo 'Australia/Sydney' > /etc/timezoneh

# Multiple installs since my internet sucks
RUN apt-get install -y apt-utils ascii bat cargo cmake cscope curl dnsutils
RUN apt-get install -y exuberant-ctags fzf gawk gcc gcc-multilib gdb
RUN apt-get install -y gdb-multiarch git iproute2 jq libc6:i386 libdb-dev
RUN apt-get install -y libffi-dev libncurses5:i386 libpcre3-dev libssl-dev
RUN apt-get install -y libstdc++6:i386 libxaw7-dev libxt-dev locate ltrace make
RUN apt-get install -y man nasm net-tools netcat patchelf php procps psmisc
RUN apt-get install -y python python3 python3-dev python3-pip rubygems strace
RUN apt-get install -y tmux valgrind vim virtualenvwrapper wget build-essential

RUN apt-get upgrade -y

#RUN pip install capstone requests pwntools r2pipe
RUN python3 -m pip install --upgrade capstone requests pwntools

RUN pip3 install pwntools keystone-engine unicorn capstone ropper
RUN pip3 install angr colorama

RUN git clone https://github.com/JonathanSalwan/ROPgadget ~/tools/ROPgadget

RUN git clone https://github.com/radare/radare2 ~/tools/radare2 \
	&& cd ~/tools/radare2/ \
	&& sys/install.sh \
	&& r2pm init \
	&& r2pm update \
	&& r2pm rdec

RUN git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg \
	&& cd ~/tools/pwndbg/ \
	&& ./setup.sh

RUN gem install one_gadget

# For the locate command
RUN updatedb

# Enable the man command
#RUN unminimize

WORKDIR /root
