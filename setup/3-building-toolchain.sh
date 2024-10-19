#!/usr/bin/env bash

set -ex

/home/lfs/setup/3-building-toolchain/5-compile-cross-toolchain.sh
/home/lfs/setup/3-building-toolchain/6-cross-compile-temp-tools.sh
/home/lfs/setup/3-building-toolchain/7-build-temp-tools-part1.sh
/setup/3-building-toolchain/7-build-temp-tools-part2.sh
/setup/3-building-toolchain/7-build-temp-tools-part3.sh
