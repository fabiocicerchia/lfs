#!/usr/bin/env bash

set -ex

docker exec --user lfs --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/5-compile-cross-toolchain.sh'
docker exec --user lfs --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/6-cross-compile-temp-tools.sh'
# purge tmp build folders
sudo find sources -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
docker exec --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/7-build-temp-tools-part1.sh'