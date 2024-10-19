export LFS=/mnt/lfs

init:
	./setup/0-virtual-env.sh
	docker exec lfs /home/lfs/setup/1-install-deps.sh
	docker exec lfs /bin/bash -c 'cp -r /home/lfs/setup $(LFS)/setup'

preparing:
	docker exec --env-file $$PWD/setup/.env lfs /home/lfs/setup/2-preparing-build.sh

building-toolchain:
	# purge tmp build folders
	sudo find sources -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

	# TODO: is it needed?
	docker exec --workdir /home/lfs lfs bash -c 'chown -R lfs: /mnt/lfs'

	docker exec --user lfs --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/5-compile-cross-toolchain.sh'
	docker exec --user lfs --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/6-cross-compile-temp-tools.sh'

	docker exec --workdir /home/lfs -it lfs bash -c 'source .bashrc && /home/lfs/setup/3-building-toolchain/7-build-temp-tools-part1.sh'

	# /setup/3-building-toolchain/7-build-temp-tools-part2.sh
	# /setup/3-building-toolchain/7-build-temp-tools-part3.sh