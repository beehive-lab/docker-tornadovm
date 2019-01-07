#!/bin/bash

IMAGE=beehivelab/tornado-gpu
exec docker run --runtime=nvidia --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
