#!/bin/bash

IMAGE=beehivelab/tornado-intel-igpu-graalvm-jdk8:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

