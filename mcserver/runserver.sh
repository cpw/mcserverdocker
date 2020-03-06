#!/bin/sh

mkdir -p /srv/mcserver/base/mods/
cp /srv/mcserver/forge/serverpacklocator.jar /srv/mcserver/base/mods/serverpacklocator.jar

exec java ${JVM_MEM_OPTS} ${JVM_XX_OPTS} -jar $(dirname $0)/forge.jar "$@"