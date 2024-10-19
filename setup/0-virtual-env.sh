#!/usr/bin/env bash

set -ex

docker run --privileged -u root -v $PWD:/home/lfs -v $PWD/sources:/mnt/lfs/sources --name lfs -dt ubuntu:latest sleep infinity
