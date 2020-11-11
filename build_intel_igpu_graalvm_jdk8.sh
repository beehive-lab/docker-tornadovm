#!/bin/bash

IMAGE=tornado-intel-igpu-graalvm-jdk8
docker build --cpuset-cpus="0-7" -t $IMAGE -f Dockerfile.intel.igpu.graalvm.jdk8 .

TAG=0.8
docker tag $IMAGE beehivelab/$IMAGE:$TAG

TAG=latest
docker tag $IMAGE beehivelab/$IMAGE:$TAG


