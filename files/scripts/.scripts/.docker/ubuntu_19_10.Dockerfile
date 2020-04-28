# This is the generic docker file, uses the most up to date version of ubuntu

FROM ubuntu:19.10

ENV LC_CTYPE C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	 \
	&& apt-get install -y build-essential jq strace ltrace curl wget rubygems \
		gcc dnsutils netcat gcc-multilib net-tools vim gdb gdb-multiarch \
		python python3 python3-pip python3-dev libssl-dev libffi-dev wget git \
		make procps libpcre3-dev libdb-dev libxt-dev libxaw7-dev python-pip \
		libc6:i386 libncurses5:i386 libstdc++6:i386 virtualenvwrapper cmake \
		tmux locate man gawk fzf patchelf \
	\
	&& apt-get upgrade -y

RUN pip install capstone requests pwntools r2pipe

RUN pip3 install pwntools keystone-engine unicorn capstone ropper

RUN mkdir -p ~/tools

RUN git clone https://github.com/JonathanSalwan/ROPgadget ~/tools/ROPgadget

RUN git clone https://github.com/radare/radare2 ~/tools/radare2 \
	&& cd ~/tools/radare2/ \
	&& sys/install.sh

RUN git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg \
	&& cd ~/tools/pwndbg/ \
	&& ./setup.sh

RUN gem install one_gadget

COPY bashrc /root/.bashrc
COPY gdbinit /root/.gdbinit
COPY radare2 /root/.config/radare2/
COPY scripts /root/.scripts
COPY tmux.conf /root/.tmux.conf
COPY vim /root/.vim

# For the locate command
RUN updatedb

