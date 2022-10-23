#!/usr/bin/env bash
set -euETo pipefail
shopt -s inherit_errexit

latest=$(curl -fsSL https://download.docker.com/linux/static/stable/$(uname -m)/ | grep '<a' | grep -v rootless | grep -Po 'href="docker.+"' | sort -V | tail -n1 | cut -d'"' -f2)

curl -fsSL https://download.docker.com/linux/static/stable/$(uname -m)/${latest} | \
     tar -xz --strip-components=1 -C /usr/local/bin/ docker/docker
