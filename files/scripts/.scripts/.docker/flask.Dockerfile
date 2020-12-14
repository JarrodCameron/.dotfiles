# This is a container to run the COMP3900 assignment

FROM ubuntu

ENV LC_CTYPE C.UTF-8

RUN apt-get update \
	&& apt-get install -y build-essential curl fzf gcc git jq \
		locate make man-db net-tools netcat python python3-pip python3 \
		python3-dev python3-pip ripgrep tmux vim wget \
	&& apt-get upgrade -y

RUN pip3 install flask flask_restplus PyJWT

RUN pip3 install --upgrade werkzeug==0.16.0

EXPOSE 127.0.0.1:5000:5000
