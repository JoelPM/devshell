FROM <SDK>

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y sudo \
                       zsh \
                       vim \
                       emacs \
                       tmux \
                       docker-engine && \
    apt-get clean

RUN  mkdir /devshell
COPY scripts/run.sh /devshell/run.sh
COPY scripts/entry.sh /devshell/entry.sh

RUN mkdir /src

WORKDIR /src

ENTRYPOINT ["/devshell/entry.sh"]
