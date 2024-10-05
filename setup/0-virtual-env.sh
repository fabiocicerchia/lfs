#!/usr/bin/env bash

set -e

docker run --privileged -u root -v $PWD:/home/lfs -v $PWD/sources:/mnt/lfs/sources --name lfs -it ubuntu:latest bash
