#!/usr/bin/env bash
set -euETo pipefail
shopt -s inherit_errexit

uname -m
mach=$(uname -m)
if [[ ${mach} == "armv7l" ]]; then
    mach="armhf"
fi

latest=$(curl -fsSL https://download.docker.com/linux/static/stable/${mach}/ | grep '<a' | grep -v rootless | grep -Po 'href="docker.+"' | sort -V | tail -n1 | cut -d'"' -f2)

curl -fsSL https://download.docker.com/linux/static/stable/${mach}/${latest} | \
     tar -xz --strip-components=1 -C /usr/local/bin/ docker/docker
