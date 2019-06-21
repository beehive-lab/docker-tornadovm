#!/bin/bash

IMAGE=beehivelab/tornado-intel-gpu:latest
exec docker run -it --device /dev/dri:/dev/dri --rm -v $PWD:/example -w /example "$IMAGE" "$@"

