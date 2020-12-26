#!/bin/bash 

TAG_VERSION=0.9-dev

function nvidiaJDK8() {
    IMAGE=tornado-gpu
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.nvidia .
    docker tag tornado-gpu beehivelab/tornado-gpu:$TAG_VERSION
    docker tag tornado-gpu beehivelab/tornado-gpu:latest
}

function nvidiaGraalVMJDK8() {
    IMAGE=tornado-gpu-graalvm-jdk8
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.nvidia.graalvm.jdk8 .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function nvidiaGraalVMJDK11() {
    IMAGE=tornado-gpu-graalvm-jdk11
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.nvidia.graalvm.jdk11 .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function intelJDK8() {
    IMAGE=tornado-intel-gpu
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.intel.igpu .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function intelGraalVMJDK8() {
    IMAGE=tornado-intel-igpu-graalvm-jdk8
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.intel.igpu.graalvm.jdk8 .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function intelGraalVMJDK11() {
    IMAGE=tornado-intel-igpu-graalvm-jdk11
    docker build --cpuset-cpus="0-7" -t $IMAGE -f dockerFiles/Dockerfile.intel.igpu.graalvm.jdk11 .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function printHelp() {
    echo "TornadoVM docker build"
    echo "Options: "
    echo "Builds for NVIDIA GPUs:"
    echo "       --nvidia-jdk8          : Build Docker Image for NVIDIA GPUs using JDK8"
    echo "       --nvidia-graalVM-JDK8  : Build Docker Image for NVIDIA GPUs using GraalVM JDK8"
    echo "       --nvidia-graalVM-JDK11 : Build Docker Image for NVIDIA GPUs using GraalVM JDK11"
    echo -e "\nBuilds for Intel Integrated GPUs:"
    echo "       --igpu-jdk8            : Build Docker Image for Intel Integrated GPUs using JDK8"
    echo "       --igpu-graalVM-JDK8    : Build Docker Image for Intel Integrated GPUs using GraalVM JDK8"
    echo "       --igpu-graalVM-JDK11   : Build Docker Image for Intel Integrated GPUs using GraalVM JDK11"
    
    
    exit 0
}

POSITIONAL=()

if [[ $# == 0 ]] 
then
    printHelp
    exit
fi

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  --help)
    printHelp
    shift
    ;;
  --nvidia-jdk8)
    nvidiaJDK8
    shift
    ;;
  --nvidia-graalVM-JDK8)
    nvidiaGraalVMJDK8
    shift
    ;;
  --nvidia-graalVN-JDK11)
    nvidiaGraalVMJDK11
    shift
    ;;
  --intel-jdk8)
    intelJDK8
    shift
    ;;
  --intel-graalVM-JDK8)
    intelGraalVMJDK8
    shift
    ;;
  --intel-graalVN-JDK11)
    intelGraalVMJDK11
    shift
    ;;
  esac
done
