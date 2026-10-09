#!/bin/bash

## Runs a command in one of the NVIDIA TornadoVM images. Pick the image with
## TORNADOVM_IMAGE=cuda-jdk21 | cuda-jdk25 | cuda-jdk27 | opencl-jdk21 | opencl-jdk25 | opencl-jdk27
## (default: cuda-jdk25).
IMAGE=beehivelab/tornadovm-nvidia-${TORNADOVM_IMAGE:-cuda-jdk25}:latest
exec docker run --runtime=nvidia --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"
