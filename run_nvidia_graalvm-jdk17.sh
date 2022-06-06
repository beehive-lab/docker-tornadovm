#!/bin/bash

IMAGE=beehivelab/tornadovn-nvidia-graalvm-jdk17:latest
exec docker run --runtime=nvidia --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
