FROM ubuntu
RUN apt-get update && apt-get install -y curl

RUN curl -sSL https://rover.apollo.dev/nix/v0.1.9 | sh 
RUN echo 'export PATH=$HOME/.rover/bin:$PATH' >> $HOME/.bashrc
ENTRYPOINT [ "/root/.rover/bin/rover" ]
