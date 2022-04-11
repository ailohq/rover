FROM alpine

RUN apk update && apk upgrade && apk --no-cache add curl jq

RUN curl -sSL https://rover.apollo.dev/nix/v0.4.8 | sh
RUN echo 'export PATH=$HOME/.rover/bin:$PATH' >> $HOME/.bashrc

WORKDIR /home

COPY ./publishSubgraph.sh /home

ENTRYPOINT [ "/root/.rover/bin/rover" ]
