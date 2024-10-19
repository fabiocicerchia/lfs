# LFS - Linux From Scratch

## 0. Start Building Env

```bash
# standup docker container & install required deps
make init
```

## 2. Preparing for the Build

ℹ️ NOTE: jump to [RESTORE](#restoring-previous-build) if you've run the following and took a backup.

```bash
# install required deps
/home/lfs/setup/1-install-deps.sh

# configure vars
export $(cat /home/lfs/setup/.env | tr -d ' ' | xargs -L 1) && echo $LFS
```

ℹ️ NOTE: jump to [RESTORE](#restoring-previous-build) if you've run the following and took a backup.

```bash
make preparing
```

## 3. Building the LFS Cross Toolchain and Temporary Tools

```bash
cd /home/lfs
su - lfs
source ~/.bash_profile
make building-toolchain
```

At this point you might want to take a backup:

```bash
exit
./setup/7.13-backup.sh
```

From your host, copy the backup into the `backup` folder:
```bash
docker cp lfs:/root/lfs-temp-tools-12.2.tar.xz backup
```

⚠️ TODO: Drop folder `sources` from backup.

### Restoring previous build

Inside the container, start the restore process:

```bash
source /home/lfs/.bashrc && echo $LFS
HOME=/home/lfs/backup /home/lfs/setup/7.13-restore.sh

# mount sys dirs (see setup/7-build-temp-tools.sh)
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/kernfs.html
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
```

## 4. Build LFS System

```bash
/setup/8-building-system.sh
```

## ToDos

* Add comments in each script about SBUs and package descriptions.
* Store `cat EOF` in physical files and just copy them over.

## Additional Readings

* [vi. Rationale for Packages in the Book](https://www.linuxfromscratch.org/lfs/view/stable/prologue/package-choices.html)
* [4.5. About SBUs](https://linuxfromscratch.org/lfs/view/stable/chapter04/aboutsbus.html)
* [8.2. Package Management](https://linuxfromscratch.org/lfs/view/stable/chapter08/pkgmgt.html)
* [8.83. About Debugging Symbols](https://www.linuxfromscratch.org/lfs/view/stable/chapter08/aboutdebug.html)
