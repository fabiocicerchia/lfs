#!/usr/bin/env bash

set -e

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/changingowner.html
chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/kernfs.html
mkdir -pv $LFS/{dev,proc,sys,run}

mount -v --bind /dev $LFS/dev

mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/chroot.html
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/creatingdirs.html
mkdir -pv /{boot,home,mnt,opt,srv}

mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/createfiles.html
ln -sv /proc/self/mounts /etc/mtab

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

localedef -i C -f UTF-8 C.UTF-8

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

exec /usr/bin/bash --login

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

exit

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}