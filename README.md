# LFS - Linux From Scratch

## Build

```bash
# standup docker container
./setup/0-virtual-env.sh

# run the following commands inside the container
cd /home/lfs

# install required deps
./setup/1-install-deps.sh

# configure vars
export $(cat ./setup/.env | tr -d ' ' | xargs -L 1)
echo $LFS

# LFS commands
./setup/2.2-version-check.sh
./setup/2.7-partitions.sh
./setup/3.1-packages.sh
./setup/4.2-folders.sh
./setup/4.3-users.sh
su - lfs
source ~/.bash_profile
./setup/5-compile-cross-toolchain.sh
./setup/6-cross-compile-temp-tools.sh
exit # return to root
./setup/7-build-temp-tools.sh
```