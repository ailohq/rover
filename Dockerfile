FROM public.ecr.aws/docker/library/debian:bullseye-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://rover.apollo.dev/nix/v0.7.0 | sh -s -- --force

COPY ./publishSubgraph.sh /app
COPY ./seedGraph.sh /app

ENTRYPOINT [ "rover" ]
