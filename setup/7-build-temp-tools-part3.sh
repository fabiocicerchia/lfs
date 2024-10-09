#!/usr/bin/env bash

set -ex

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/gettext.html
tar xvf gettext*.xz
cd $(find $PWD -maxdepth 1 -name "gettext-*" -type d)

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/bison.html
tar xvf bison*.xz
cd $(find $PWD -maxdepth 1 -name "bison-*" -type d)

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make
make install

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/perl.html
tar xvf perl*.xz
cd $(find $PWD -maxdepth 1 -name "perl-*" -type d)

sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.40/core_perl     \
             -D archlib=/usr/lib/perl5/5.40/core_perl     \
             -D sitelib=/usr/lib/perl5/5.40/site_perl     \
             -D sitearch=/usr/lib/perl5/5.40/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl

make
make install

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/Python.html
tar xvf Python*.xz
cd $(find $PWD -maxdepth 1 -name "Python-*" -type d)

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make
make install

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/texinfo.html
tar xvf texinfo*.xz
cd $(find $PWD -maxdepth 1 -name "texinfo-*" -type d)

./configure --prefix=/usr

make
make install

cd $LFS/sources
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/util-linux.html
tar xvf util-linux*.xz
cd $(find $PWD -maxdepth 1 -name "util-linux-*" -type d)

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.2

make
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/cleanup.html
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
