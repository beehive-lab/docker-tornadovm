#!/bin/bash

IMAGE=tornado-gpu-graalvm-jdk11
docker build --cpuset-cpus="0-7" -t $IMAGE -f Dockerfile.nvidia.graalvm.jdk11 .

TAG=0.7
docker tag $IMAGE beehivelab/$IMAGE:$TAG

TAG=latest
docker tag $IMAGE beehivelab/$IMAGE:$TAG



