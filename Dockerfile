FROM alpine

RUN apk update && apk upgrade && apk --no-cache add curl jq

RUN curl -sSL https://rover.apollo.dev/nix/v0.4.8 | sh
RUN echo 'export PATH=$HOME/.rover/bin:$PATH' >> $HOME/.bashrc

COPY ./publishSubgraph.sh /home

WORKDIR /home

ENTRYPOINT [ "/root/.rover/bin/rover" ]
