FROM openjdk:8-jdk-alpine

ARG FORGE_VERSION
ARG SPL_VERSION

LABEL "FORGE" "${FORGE_VERSION}"
LABEL "SPL" "${SPL_VERSION}"
LABEL "author" "cpw"

RUN apk add --no-cache -U \
  openssl \
  screen \
  util-linux \
  shadow \
  curl iputils wget \
  nano \
  python python-dev py2-pip

RUN pip install mcstatus yq

HEALTHCHECK CMD mcstatus localhost:25565 ping

RUN addgroup -g 1000 minecraft \
  && adduser -Ss /bin/false -u 1000 -G minecraft -h /srv/mcserver minecraft \
  && mkdir -m 777 -p /srv/mcserver/base \
  && chown -R minecraft:minecraft /srv/mcserver

EXPOSE 25565 8443

USER 1000

RUN cd /srv/mcserver/ \
&& wget https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar \
&& java -jar forge-${FORGE_VERSION}-installer.jar --installServer /srv/mcserver/forge \
&& ln -s /srv/mcserver/forge/forge-${FORGE_VERSION}.jar /srv/mcserver/forge/forge.jar

RUN cd /srv/mcserver/ \
&& wget https://files.minecraftforge.net/maven/cpw/mods/forge/serverpacklocator/${SPL_VERSION}/serverpacklocator-${SPL_VERSION}.jar \
&& cp /srv/mcserver/serverpacklocator-${SPL_VERSION}.jar /srv/mcserver/forge/serverpacklocator.jar

ADD runserver.sh /srv/mcserver/forge/runserver.sh
ADD signcertificate.sh /srv/mcserver/forge/signcertificate.sh

VOLUME ["/srv/mcserver/base"]
ENV UID=1000 GID=1000 
ENV JVM_MEM_OPTS="-Xmx12G -Xms12G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"
ENV JVM_XX_OPTS="-Xloggc:/srv/mcserver/base/gc.log -verbose:gc -XX:+PrintGCDateStamps"

WORKDIR /srv/mcserver/base
ENTRYPOINT ["/srv/mcserver/forge/runserver.sh","nogui"]
