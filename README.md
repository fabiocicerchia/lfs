# LFS - Linux From Scratch

## 0. Start Building Env

```bash
# standup docker container
./setup/0-virtual-env.sh
```

## 2. Preparing for the Build

ℹ️ NOTE: jump to [RESTORE](#restoring-previous-build) if you've run the following and took a backup.

```bash
# run the following commands inside the container
cd /home/lfs

# install required deps
./setup/1-install-deps.sh

# configure vars
export $(cat ./setup/.env | tr -d ' ' | xargs -L 1)
echo $LFS

# LFS commands
# NOTE: jump to RESTORE if you've run the following and took a backup
./setup/2.2-version-check.sh
./setup/2.7-partitions.sh
./setup/3.1-packages.sh
./setup/4.2-folders.sh
./setup/4.3-users.sh
```

## 3. Building the LFS Cross Toolchain and Temporary Tools

```bash
su - lfs
source ~/.bash_profile
./setup/5-compile-cross-toolchain.sh
./setup/6-cross-compile-temp-tools.sh
exit # return to root
./setup/7-build-temp-tools.sh
```

At this point you might want to take a backup:

```bash
./setup/7.13-backup.sh
```

From your host, copy the backup into the `backup` folder:
```bash
docker cp lfs:/root/lfs-temp-tools-12.2.tar.xz backup
```

⚠️ TODO: Drop folder `sources` from backup.

### Restoring previous build

On your host, start the restore process:

```bash
docker run --privileged -u root -v $PWD:/home/lfs --name lfs -it ubuntu:latest bash
source /home/lfs/.bashrc
mkdir $LFS

# install required deps
/home/lfs/setup/1-install-deps.sh
HOME=/home/lfs/backup /home/lfs/setup/7.13-restore.sh
```

## 4. Build LFS System

```bash
# add usr/sbin for missing chroot in PATH
export PATH=$LFS/usr/sbin:$PATH
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login
```

## ToDos

* Add comments in each script about SBUs and package descriptions.
* Store `cat EOF` in physical files and just copy them over.

## Additional Readings

* [vi. Rationale for Packages in the Book](https://www.linuxfromscratch.org/lfs/view/stable/prologue/package-choices.html)
* [4.5. About SBUs](https://linuxfromscratch.org/lfs/view/stable/chapter04/aboutsbus.html)
* [8.2. Package Management](https://linuxfromscratch.org/lfs/view/stable/chapter08/pkgmgt.html)
* [8.83. About Debugging Symbols](https://www.linuxfromscratch.org/lfs/view/stable/chapter08/aboutdebug.html)