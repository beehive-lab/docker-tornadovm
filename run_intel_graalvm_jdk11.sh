#!/bin/bash

IMAGE=tornado-intel-igpu-graalvm-jdk11:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

