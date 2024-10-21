#!/usr/bin/env bash

set -ex

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/cleanup.html

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

cd $LFS
tar -cJpf $HOME/lfs-temp-tools-12.2.tar.xz .