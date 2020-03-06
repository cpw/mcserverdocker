FROM openjdk:8-jdk-alpine as forgeinstall
WORKDIR /tmp
ARG MC_VERSION
ARG FORGE_VERSION
RUN cd /tmp \
&& wget -O installer.jar https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar \
&& java -jar installer.jar --installServer /tmp/forge \
&& cd /tmp/forge \
&& ln -s forge-${FORGE_VERSION}.jar forge.jar

FROM scratch as splinstall
WORKDIR /tmp
ARG SPL_VERSION
ADD https://files.minecraftforge.net/maven/cpw/mods/forge/serverpacklocator/${SPL_VERSION}/serverpacklocator-${SPL_VERSION}.jar /tmp/serverpacklocator.jar


FROM openjdk:8-jdk-alpine

LABEL "author" "cpw"

RUN apk add --no-cache -U \
  tini \
  openssl \
  util-linux \
  shadow \
  nano \
  python3 python3-dev py3-pip

RUN pip3 install mcstatus

HEALTHCHECK CMD mcstatus localhost:25565 ping

RUN addgroup -g 1000 minecraft \
  && adduser -Ss /bin/false -u 1000 -G minecraft -h /srv/mcserver minecraft \
  && mkdir -m 777 -p /srv/mcserver/base \
  && mkdir -m 777 -p /srv/mcserver/forge \
  && chown -R minecraft:minecraft /srv/mcserver

EXPOSE 25565 8443

USER 1000
ENV UID=1000
ENV GID=1000 

WORKDIR /srv/mcserver/base

VOLUME ["/srv/mcserver/base"]
ENV JVM_MEM_OPTS="-Xmx12G -Xms12G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"
ENV JVM_XX_OPTS="-Xloggc:/srv/mcserver/base/gc.log -verbose:gc -XX:+PrintGCDateStamps -Dfml.queryResult=confirm"

ADD runserver.sh /srv/mcserver/forge/runserver.sh
ADD signcertificate.sh /srv/mcserver/forge/signcertificate.sh

ARG FORGE_VERSION
ARG SPL_VERSION
ENV SPL_VERSION=${SPL_VERSION}
ENV FORGE_VERSION=${FORGE_VERSION}

LABEL "SPL" "${SPL_VERSION}"
LABEL "FORGE" "${FORGE_VERSION}"
COPY --chown=minecraft:minecraft --from=splinstall /tmp/serverpacklocator.jar /srv/mcserver/forge/
COPY --chown=minecraft:minecraft --from=forgeinstall /tmp/forge/ /srv/mcserver/forge/

ENTRYPOINT ["/sbin/tini","--"]
CMD ["/srv/mcserver/forge/runserver.sh","nogui"]
