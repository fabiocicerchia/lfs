#!/usr/bin/env bash
# https://www.linuxfromscratch.org/lfs/view/stable/chapter04/addinguser.html

set -e

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# passwd lfs # TODO

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac