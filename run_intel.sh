#!/bin/bash

IMAGE=tornado-intel-igpu:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

