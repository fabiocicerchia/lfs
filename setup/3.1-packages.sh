#!/bin/bash
# https://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html

LFS=. # CUSTOM
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

source .env
ln -s $PWD/sources $LFS/ # CUSTOM

wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv -O wget-list-sysv
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources

wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums --directory-prefix=$LFS/sources
pushd $LFS/sources
  md5sum -c md5sums
popd

chown root:root $LFS/sources/*
