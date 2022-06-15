#!/bin/bash

IMAGE=beehivelab/tornadovm-intel-graalvm:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

