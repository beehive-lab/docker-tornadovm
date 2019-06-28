#!/bin/bash

IMAGE=beehivelab/tornado-gpu:latest
exec docker run --runtime=nvidia --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
