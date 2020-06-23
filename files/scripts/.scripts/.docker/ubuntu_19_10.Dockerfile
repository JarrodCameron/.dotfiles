# This is the generic docker file, uses the most up to date version of ubuntu

FROM ubuntu:19.10

ENV LC_CTYPE C.UTF-8

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	 \
	&& apt-get install -y apt-utils ascii build-essential cmake curl dnsutils \
		fzf gawk gcc gcc-multilib gdb gdb-multiarch git iproute2 jq \
		libc6:i386 libdb-dev libffi-dev libncurses5:i386 libpcre3-dev \
		libssl-dev libstdc++6:i386 libxaw7-dev libxt-dev locate ltrace make \
		man nasm net-tools netcat patchelf procps python python-pip python3 \
		python3-dev python3-pip ripgrep rubygems strace tmux vim \
		virtualenvwrapper wget wget \
	\
	&& apt-get upgrade -y

#RUN pip install capstone requests pwntools r2pipe
RUN pip install capstone requests pwntools

RUN pip3 install pwntools keystone-engine unicorn capstone ropper colorama

RUN git clone https://github.com/JonathanSalwan/ROPgadget ~/tools/ROPgadget

RUN git clone https://github.com/radare/radare2 ~/tools/radare2 \
	&& cd ~/tools/radare2/ \
	&& sys/install.sh

RUN git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg \
	&& cd ~/tools/pwndbg/ \
	&& ./setup.sh

RUN gem install one_gadget

# For the locate command
RUN updatedb

# Enable the man command
#RUN unminimize
