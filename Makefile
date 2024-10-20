export LFS=/mnt/lfs

init:
	./setup/0-virtual-env.sh
	docker exec lfs /home/lfs/setup/1-install-deps.sh
	docker exec lfs /bin/bash -c 'cp -r /home/lfs/setup $(LFS)/setup'

preparing:
	docker exec --env-file $$PWD/setup/.env lfs /home/lfs/setup/2-preparing-build.sh

building-toolchain:
	/setup/3-building-toolchain.sh
	/setup/4-building/8-building-system.sh
