#!/usr/bin/env bash

set -ex

export TZ="Etc/UTC"
export DEBIAN_FRONTEND=noninteractive

apt update \
&& apt install -y \
    binutils \
    bison \
    gcc \
    m4 \
    python3 \
    texinfo \
    gawk \
    g++ \
    make \
    patch \
    xz-utils \
    wget
