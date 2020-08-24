FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y apt-transport-https gnupg2 wget \
    && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
    && apt-get update \
    && apt-get install dart

ENV PATH="/usr/lib/dart/bin:${PATH}"

COPY . /workspace

WORKDIR /workspace

RUN pub get
RUN dart2native lib/main.dart -o /kyaru-dev

WORKDIR /

RUN rm -rf /workspace

COPY docker/wait-for-it.sh wait-for-it.sh

ENTRYPOINT ["./wait-for-it.sh", "mongo:27017", "--timeout=30", "--", "./kyaru-dev"]