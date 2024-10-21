#!/usr/bin/env bash

set -ex

/home/lfs/setup/2-preparing-build/2.2-version-check.sh
/home/lfs/setup/2-preparing-build/2.7-partitions.sh
# /home/lfs/setup/2-preparing-build/3.1-packages.sh # TODO: RESTORE
/home/lfs/setup/2-preparing-build/4.2-folders.sh
/home/lfs/setup/2-preparing-build/4.3-users.sh