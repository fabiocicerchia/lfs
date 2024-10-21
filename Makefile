export LFS=/mnt/lfs

init:
	./setup/0-virtual-env.sh
	docker exec lfs /home/lfs/setup/1-install-deps.sh
	docker exec lfs /bin/bash -c 'cp -r /home/lfs/setup $(LFS)/setup'

preparing:
	docker exec --env-file $$PWD/setup/.env lfs /home/lfs/setup/2-preparing-build.sh

building-toolchain:
	$$PWD/setup/3-building-toolchain.sh

building-toolchain-chroot:
	/setup/3-building-toolchain/7-build-temp-tools-part2.sh
	/setup/3-building-toolchain/7-build-temp-tools-part3.sh

building-lfs:
	$$PWD/setup/4-building/8-building-system.sh
