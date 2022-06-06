#!/bin/bash

IMAGE=tornadovm-intel-openjdk:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

