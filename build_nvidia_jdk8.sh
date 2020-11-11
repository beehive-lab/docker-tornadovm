#!/bin/bash

IMAGE=tornado-gpu
docker build --cpuset-cpus="0-7" -t $IMAGE -f Dockerfile.nvidia .

TAG=0.8
docker tag tornado-gpu beehivelab/tornado-gpu:$TAG

TAG=latest
docker tag tornado-gpu beehivelab/tornado-gpu:$TAG

