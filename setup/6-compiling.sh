#!/bin/bash

source .env

su - lfs
source ~/.bash_profile

cd /mnt/lfs/sources/

# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/m4.html
tar xvf m4*.xz
cd m4*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/ncurses.html
tar xvf ncurses*.xz
cd ncurses*

sed -i s/mawk// configure
mkdir build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping
make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/bash.html
tar xvf bash*.xz
cd bash*

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc              \
            bash_cv_strtold_broken=no
make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/coreutils.html
tar xvf coreutils*.xz
cd coreutils*

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/diffutils.html
tar xvf diffutils*.xz
cd diffutils*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html
tar xvf file*.xz
cd file*

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/findutils.html
tar xvf findutils*.xz
cd findutils*

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gawk.html
tar xvf gawk*.xz
cd gawk*

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/grep.html
tar xvf grep*.xz
cd grep*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html
tar xvf gzip*.xz
cd gzip*

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/make.html
tar xvf make*.xz
cd make*

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html
tar xvf patch*.xz
cd patch*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/sed.html
tar xvf sed*.xz
cd sed*

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/tar.html
tar xvf tar*.xz
cd tar*

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/xz.html
tar xvf xz*.xz
cd xz*

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.6.2

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd ..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/binutils-pass2.html
cd binutil*
rm -rf build

sed '6009s/$add_dir//' -i ltmain.sh

mkdir -v build
cd       build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

cd ../..
# https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gcc-pass2.html
cd gcc*

rm -rf build mpfr gmp mpc

tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd       build

../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++

make
make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc