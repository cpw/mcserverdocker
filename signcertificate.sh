#!/bin/sh

exec java -cp $(dirname $0)/serverpacklocator.jar cpw.mods.forge.serverpacklocator.cert.CertSigner "$@"