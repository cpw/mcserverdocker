#!/bin/sh

eval $(curl -s https://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json | jq -r '.promos | to_entries | sort_by( .key | capture("(?<maj>[0-9]+).(?<min>[0-9]+).(?<pat>[0-9]+)-(?<tag>[a-z]+)") | select (.tag=="latest") | .min | tonumber) | .[-1] | @sh "MC_VERSION=\(.key | split("-") | .[0]) S_FORGE_VERSION=\(.value)"')

export FORGE_VERSION=${MC_VERSION}-${S_FORGE_VERSION}
export MC_VERSION

export SPL_VERSION=$(curl -s https://files.minecraftforge.net/maven/cpw/mods/forge/serverpacklocator/maven-metadata.xml | xmllint --xpath '/metadata/versioning/release/text()' -)

docker-compose -f mcserver/docker-compose.yaml build --build-arg FORGE_VERSION --build-arg SPL_VERSION --build-arg MC_VERSION