FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://rover.apollo.dev/nix/v0.6.0 | sh
RUN echo 'export PATH=$HOME/.rover/bin:$PATH' >> $HOME/.bashrc

WORKDIR /home

COPY ./publishSubgraph.sh /home
COPY ./seedGraph.sh /home

ENTRYPOINT [ "/root/.rover/bin/rover" ]
