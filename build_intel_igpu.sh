#!/bin/bash

IMAGE=tornado-intel-igpu
docker build --cpuset-cpus="0-7" -t $IMAGE -f Dockerfile-intel-igpu .

TAG=0.3
docker tag tornado-intel-igpu beehivelab/tornado-intel-gpu:$TAG

TAG=latest
docker tag tornado-intel-igpu beehivelab/tornado-intel-gpu:$TAG


