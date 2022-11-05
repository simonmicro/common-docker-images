FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y inotify-tools procps && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
