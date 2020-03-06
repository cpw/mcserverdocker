FROM tmaier/docker-compose:latest

RUN apk add --no-cache curl jq libxml2-utils && mkdir -p /build/mcserver

COPY mcserver /build/mcserver
COPY build.sh /build/

WORKDIR /build

ENTRYPOINT /bin/sh build.sh