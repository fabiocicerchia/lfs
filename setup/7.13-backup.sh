#!/usr/bin/env bash

set -e

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/cleanup.html

cd $LFS
tar -cJpf $HOME/lfs-temp-tools-12.2.tar.xz .