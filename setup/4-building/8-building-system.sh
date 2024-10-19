#!/bin/bash

# drop all extracted tools
find /sources -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-pages.html
TOOL=man-pages; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

rm -v man3/crypt*
make prefix=/usr install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iana-etc.html
TOOL=iana-etc; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)
cp services protocols /etc

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/glibc.html
TOOL=glibc; tar xvf "$LFS/sources/$TOOL"*.xz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

patch -Np1 -i ../glibc-2.40-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=4.19                     \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib

make
# TODO:
# cc1plus: fatal error: /dev/fd/63: No such file or directory
# https://askubuntu.com/questions/1086617/dev-fd-63-no-such-file-or-directory
make check

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

make localedata/install-locales

localedef -i C -f UTF-8 C.UTF-8
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2024a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

tzselect

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zlib.html
TOOL=zlib; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make
make check
make install

rm -fv /usr/lib/libz.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bzip2.html
TOOL=bzip2; tar xvf "$LFS/sources/$TOOL"*.gz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean

make
make PREFIX=/usr install

cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

rm -fv /usr/lib/libbz2.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xz.html
TOOL=xz; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.6.2

make
make check
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/lz4.html
TOOL=lz4; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

make BUILD_STATIC=no PREFIX=/usr
make -j1 check
make BUILD_STATIC=no PREFIX=/usr install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zstd.html
TOOL=zstd; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

make prefix=/usr
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/file.html
TOOL=file; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr
make
make check
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/readline.html
TOOL=readline; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2.13

make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/m4.html
TOOL=m4; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make
make check
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bc.html
TOOL=bc; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

CC=gcc ./configure --prefix=/usr -G -O3 -r

make
make test
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/flex.html
TOOL=flex; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make
make check
make install

ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/tcl.html
TOOL=tcl; tar xvf "$LFS/sources/$TOOL"*src* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL*" -type d)

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath

make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.7|/usr/lib/tdbc1.1.7|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7|/usr/include|"            \
    -i pkgs/tdbc1.1.7/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.4|/usr/lib/itcl4.2.4|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.4/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.4|/usr/include|"            \
    -i pkgs/itcl4.2.4/itclConfig.sh

unset SRCDIR

make test
make install

chmod -v u+w /usr/lib/libtcl8.6.so

make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh

mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

cd ..
tar -xf ../tcl8.6.14-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.14
cp -v -r ./html/* /usr/share/doc/tcl-8.6.14

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/expect.html
TOOL=expect; tar xvf "$LFS/sources/$TOOL"*.gz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc14-1.patch

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make
make test
make install

ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/dejagnu.html
TOOL=dejagnu; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi

make check
make install

install -v -dm755 /usr/share/doc/dejagnu-1.6.3
install -v -m644  doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/pkgconf.html
TOOL=pkgconf; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.3.0

make
make install

ln -sv pkgconf /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/binutils.html
TOOL=binutils; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make tooldir=/usr
make -k check
grep '^FAIL:' $(find -name '*.log')

make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gmp.html
TOOL=gmp; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpfr.html
TOOL=mpfr; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1

make
make html

make check

make install
make install-html

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpc.html
TOOL=mpc; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

make check

make install
make install-html

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/attr.html
TOOL=attr; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make
make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/acl.html
TOOL=acl; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2

make
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libcap.html
TOOL=libcap; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

make test
make prefix=/usr lib=lib install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libxcrypt.html
TOOL=libxcrypt; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

make
make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/shadow.html
TOOL=shadow; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32

make
make exec_prefix=/usr install
make -C man install-man

pwconv
grpconv
mkdir -p /etc/default
useradd -D --gid 999

# passwd root

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gcc.html
TOOL=gcc; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib
             
make

ulimit -s -H unlimited

sed -e '/cpython/d'               -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
sed -e 's/no-pic /&-no-pie /'     -i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
sed -e 's/300000/(1|300000)/'     -i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
sed -e 's/{ target nonpic } //' \
    -e '/GOTPCREL/d'              -i ../gcc/testsuite/gcc.target/i386/fentryname3.c

chown -R tester .
su tester -c "PATH=$PATH make -k check"

../contrib/test_summary

make install

chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}

ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/ncurses.html
TOOL=ncurses; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

make

make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so
cp -v -R doc -T /usr/share/doc/ncurses-6.5

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sed.html
TOOL=sed; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make
make html

chown -R tester .
su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/psmisc.html
TOOL=psmisc; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check
make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gettext.html
TOOL=gettext; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.5

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bison.html
TOOL=bison; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/grep.html
TOOL=grep; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i "s/echo/#echo/" src/egrep.sh

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bash.html
TOOL=bash; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            bash_cv_strtold_broken=no \
            --docdir=/usr/share/doc/bash-5.2.32
            
make

chown -R tester .

su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install

# TODO: breaks flow/split sh
# exec /usr/bin/bash --login

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libtool.html
TOOL=libtool; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make -k check

make install
rm -fv /usr/lib/libltdl.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gdbm.html
TOOL=gdbm; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gperf.html
TOOL=gperf; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make

make -j1 check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/expat.html
TOOL=expat; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.2

make

make check

make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.2

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/inetutils.html
TOOL=inetutils; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
            
make

make check

make install

mv -v /usr/{,s}bin/ifconfig

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/less.html
TOOL=less; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --sysconfdir=/etc

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/perl.html
TOOL=perl; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.40/core_perl      \
             -D archlib=/usr/lib/perl5/5.40/core_perl      \
             -D sitelib=/usr/lib/perl5/5.40/site_perl      \
             -D sitearch=/usr/lib/perl5/5.40/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads

make

TEST_JOBS=$(nproc) make test_harness

make install
unset BUILD_ZLIB BUILD_BZIP2

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xml-parser.html
TOOL=XML-Parser; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

perl Makefile.PL

make

make test

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/intltool.html
TOOL=intltool; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/autoconf.html
TOOL=autoconf; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/automake.html
TOOL=automake; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17

make

make -j$(($(nproc)>4?$(nproc):4)) check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/openssl.html
TOOL=openssl; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
         
make

HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.3.1

cp -vfr doc/* /usr/share/doc/openssl-3.3.1

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kmod.html
TOOL=kmod; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-openssl    \
            --with-xz         \
            --with-zstd       \
            --with-zlib       \
            --disable-manpages

make

make install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
  rm -fv /usr/bin/$target
done

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libelf.html
TOOL=libelf; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libffi.html
TOOL=libffi; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/Python.html
TOOL=Python; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations
            
make

make test TESTOPTS="--timeout 120"

make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.12.5/html

tar --no-same-owner \
    -xvf ../python-3.12.5-docs-html.tar.bz2
cp -R --no-preserve=mode python-3.12.5-docs-html/* \
    /usr/share/doc/python-3.12.5/html

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/flit-core.html
TOOL=flit-core; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist flit_core

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/wheel.html
TOOL=wheel; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links=dist wheel

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/setuptools.html
TOOL=setuptools; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist setuptools

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/ninja.html
TOOL=ninja; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

export NINJAJOBS=4

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/meson.html
TOOL=meson; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/coreutils.html
TOOL=coreutils; tar xvf "$LFS/sources/$TOOL"*.xz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

patch -Np1 -i ../coreutils-9.5-i18n-2.patch

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

make NON_ROOT_USERNAME=tester check-root

groupadd -g 102 dummy -U tester
chown -R tester .

su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
   < /dev/null

groupdel dummy

make install

mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/check.html
TOOL=check; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --disable-static

make

make check

make docdir=/usr/share/doc/check-0.15.2 install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/diffutils.html
TOOL=diffutils; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gawk.html
TOOL=gawk; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

chown -R tester .
# TODO: this freezes
su tester -c "PATH=$PATH make check"

rm -f /usr/bin/gawk-5.3.0
make install

ln -sv gawk.1 /usr/share/man/man1/awk.1

mkdir -pv                                   /usr/share/doc/gawk-5.3.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/findutils.html
TOOL=findutils; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/groff.html
TOOL=groff; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

PAGE=<paper_size> ./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/grub.html
TOOL=grub; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

echo depends bli part_gpt > grub-core/extra_deps.lst

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

make

make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gzip.html
TOOL=gzip; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iproute2.html
TOOL=iproute2; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns

make SBINDIR=/usr/sbin install

mkdir -pv             /usr/share/doc/iproute2-6.10.0
cp -v COPYING README* /usr/share/doc/iproute2-6.10.0

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kbd.html
TOOL=kbd; tar xvf "$LFS/sources/$TOOL"*.xz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

patch -Np1 -i ../kbd-2.6.4-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make

make check

make install

cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libpipeline.html
TOOL=libpipeline; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/make.html
TOOL=make; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

chown -R tester .

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/patch.html
TOOL=patch; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/tar.html
TOOL=tar; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

FORCE_UNSAFE_CONFIGURE=1 \
./configure --prefix=/usr

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/texinfo.html
TOOL=texinfo; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/vim.html
TOOL=vim; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -R tester .

# TODO: this freezes
su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
   &> vim-test.log
   
make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0660

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

# TODO: this will break flow / split it
# vim -c ':options'

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/markupsafe.html
TOOL=markupsafe; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist Markupsafe

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/jinja2.html
TOOL=jinja2; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Jinja2

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/udev.html
TOOL=udev; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in

sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

mkdir -p build
cd       build

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D mode=release           \
      -D dev-kvm-mode=0660      \
      -D link-udev-shared=false \
      -D logind=false           \
      -D vconsole=false
      
export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
                      awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')
                      
ninja udevadm systemd-hwdb                                           \
      $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
      $(realpath libudev.so --relative-to .)                         \
      $udev_helpers

install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
install -vm755 -d /usr/{lib,share}/pkgconfig
install -vm755 udevadm                             /usr/bin/
install -vm755 systemd-hwdb                        /usr/bin/udev-hwdb
ln      -svfn  ../bin/udevadm                      /usr/sbin/udevd
cp      -av    libudev.so{,*[0-9]}                 /usr/lib/
install -vm644 ../src/libudev/libudev.h            /usr/include/
install -vm644 src/libudev/*.pc                    /usr/lib/pkgconfig/
install -vm644 src/udev/*.pc                       /usr/share/pkgconfig/
install -vm644 ../src/udev/udev.conf               /etc/udev/
install -vm644 rules.d/* ../rules.d/README         /usr/lib/udev/rules.d/
install -vm644 $(find ../rules.d/*.rules \
                      -not -name '*power-switch*') /usr/lib/udev/rules.d/
install -vm644 hwdb.d/*  ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/
install -vm755 $udev_helpers                       /usr/lib/udev
install -vm644 ../network/99-default.link          /usr/lib/udev/network

tar -xvf ../../udev-lfs-20230818.tar.xz
make -f udev-lfs-20230818/Makefile.lfs install

tar -xf ../../systemd-man-pages-256.4.tar.xz                            \
    --no-same-owner --strip-components=1                              \
    -C /usr/share/man --wildcards '*/udev*' '*/libudev*'              \
                                  '*/systemd.link.5'                  \
                                  '*/systemd-'{hwdb,udevd.service}.8

sed 's|systemd/network|udev/network|'                                 \
    /usr/share/man/man5/systemd.link.5                                \
  > /usr/share/man/man5/udev.link.5

sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8   \
                               > /usr/share/man/man8/udev-hwdb.8

sed 's|lib.*udevd|sbin/udevd|'                                        \
    /usr/share/man/man8/systemd-udevd.service.8                       \
  > /usr/share/man/man8/udevd.8

rm /usr/share/man/man*/systemd*

unset udev_helpers

udev-hwdb update

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-db.html
TOOL=man-db; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.12.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=
            
make

make check

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/procps-ng.html
TOOL=procps-ng; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.4 \
            --disable-static                        \
            --disable-kill
            
make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/util-linux.html
TOOL=util-linux; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.2

make

touch /etc/fstab
chown -R tester .
su tester -c "make -k check"

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/e2fsprogs.html
TOOL=e2fsprogs; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

mkdir -v build
cd       build

../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
             
make

make check

make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sysklogd.html
TOOL=sysklogd; tar xvf "$LFS/sources/$TOOL"* -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --runstatedir=/run \
            --without-logger

make

make install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# Do not open any internet ports.
secure_mode 2

# End /etc/syslog.conf
EOF

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sysvinit.html
TOOL=sysvinit; tar xvf "$LFS/sources/$TOOL"*.xz -C $LFS/sources/ && cd $(find $LFS/sources -maxdepth 1 -name "$TOOL-*" -type d)

patch -Np1 -i ../sysvinit-3.10-consolidated-1.patch

make

make install

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/stripping.html
save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.33
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug --compress-debug-sections=zlib $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

online_usrbin="bash find strip"
online_usrlib="libbfd-2.43.1.so
               libsframe.so.1.0.0
               libhistory.so.8.2
               libncursesw.so.6.5
               libm.so.6
               libreadline.so.8.2
               libz.so.1.3.1
               libzstd.so.1.5.6
               $(cd /usr/lib; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/$BIN /tmp/$BIN
    strip --strip-unneeded /tmp/$BIN
    install -vm755 /tmp/$BIN /usr/bin
    rm /tmp/$BIN
done

for LIB in $online_usrlib; do
    cp /usr/lib/$LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-unneeded $i
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib

# https://www.linuxfromscratch.org/lfs/view/stable/chapter08/cleanup.html

rm -rf /tmp/{*,.*}

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester