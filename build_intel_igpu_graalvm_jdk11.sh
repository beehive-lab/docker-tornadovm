#!/bin/bash

IMAGE=tornado-intel-igpu-graalvm-jdk11
docker build --cpuset-cpus="0-7" -t $IMAGE -f Dockerfile-intel-igpu.graalvm.jdk11 .

TAG=0.6
docker tag $IMAGE beehivelab/$IMAGE:$TAG

TAG=latest
docker tag $IMAGE beehivelab/$IMAGE:$TAG


