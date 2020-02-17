#!/bin/bash

IMAGE=beehivelab/tornado-gpu-graalvm-jdk11:latest
exec docker run --runtime=nvidia --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
