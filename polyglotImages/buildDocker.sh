#!/usr/bin/env bash

TAG_VERSION=1.0.4-dev

function buildDockerImage() {
    IMAGE=$1
    FILE=$2
    docker build -t $IMAGE -f $FILE .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}


if [[ "$1" == "--python" ]]; then
    docker volume create data
    #buildDockerImage "tornadovm-polyglot-graalpy-23.1.0-oneapi-intel-container" "./polyglot-graalpy/Dockerfile.intel.oneapi.graalpy.jdk21"
    buildDockerImage "tornadovm-polyglot-graalpy-23.1.0-nvidia-opencl-container" "./polyglot-graalpy/Dockerfile.nvidia.opencl.graalpy.jdk21"
elif [[ "$1" == "--js" ]]; then
    docker volume create data
    buildDockerImage "tornadovm-polyglot-graaljs-23.1.0-nvidia-opencl-container" "./polyglot-graaljs/Dockerfile.nvidia.opencl.graaljs.jdk21"
elif [[ "$1" == "--ruby" ]]; then
    docker volume create data
    buildDockerImage "tornadovm-polyglot-truffleruby-23.1.0-nvidia-opencl-container" "./polyglot-truffleruby/Dockerfile.nvidia.opencl.truffleruby.jdk21"
elif [[ "$1" == "--deleteVolume" ]]; then
    docker volume rm data
elif [[ "$1" == "--all" ]]; then
    docker volume create data
    buildDockerImage "tornadovm-polyglot-graalpy-23.1.0-oneapi-intel-container" "./polyglot-graalpy/Dockerfile.intel.oneapi.graalpy.jdk21"
    buildDockerImage "tornadovm-polyglot-graalpy-23.1.0-nvidia-opencl-container" "./polyglot-graalpy/Dockerfile.nvidia.opencl.graalpy.jdk21"
    buildDockerImage "tornadovm-polyglot-graaljs-23.1.0-nvidia-opencl-container" "./polyglot-graaljs/Dockerfile.nvidia.opencl.graaljs.jdk21"
    buildDockerImage "tornadovm-polyglot-truffleruby-23.1.0-nvidia-opencl-container" "./polyglot-truffleruby/Dockerfile.nvidia.opencl.truffleruby.jdk21"
elif [[ "$1" == "--help" ]] || [[ "$1" == "--h" ]]; then
    echo "Please run:"
    echo "  ./buildDocker.sh --python		to create a volume and build the docker image for tornadovm-graalpy, or"
    echo "  ./buildDocker.sh --js		to create a volume and build the docker image for tornadovm-graaljs, or"
    echo "  ./buildDocker.sh --ruby		to create a volume and build the docker image for tornadovm-truffleruby, or"
    echo "  ./buildDocker.sh --all		to create a volume and build all docker images, or"
    echo "  ./buildDocker.sh --deleteVolume	to delete the generated volume, or"
    echo "  ./buildDocker.sh --help		to print help message"
else
    echo "Please run:"
    echo "  ./buildDocker.sh --python           to create a volume and build the docker image for tornadovm-graalpy, or"
    echo "  ./buildDocker.sh --js               to create a volume and build the docker image for tornadovm-graaljs, or"
    echo "  ./buildDocker.sh --ruby             to create a volume and build the docker image for tornadovm-truffleruby, or"
    echo "  ./buildDocker.sh --all              to create a volume and build all docker images, or"
    echo "  ./buildDocker.sh --deleteVolume     to delete the generated volume, or"
    echo "  ./buildDocker.sh --help             to print help message"
fi
