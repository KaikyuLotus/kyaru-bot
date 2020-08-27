FROM ubuntu:20.04

RUN apt-get update  --no-install-recommends \
    && apt-get install -y --no-install-recommends \
        apt-transport-https=2.0.2ubuntu0.1 \
        gnupg2=2.2.19-3ubuntu2 \
        wget=1.20.3-1ubuntu1 \
    && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
    && apt-get update \
    && apt-get install -y dart=2.9.2-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/dart/bin:${PATH}"

COPY . /workspace

WORKDIR /workspace

RUN pub get
RUN dart2native bin/main.dart -o /kyaru-dev

WORKDIR /

RUN rm -rf /workspace

COPY docker/wait-for-it.sh wait-for-it.sh

ENTRYPOINT ["./wait-for-it.sh", "mongo:27017", "--timeout=30", "--", "./kyaru-dev"]