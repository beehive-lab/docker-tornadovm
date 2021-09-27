#!/bin/bash 

TAG_VERSION=0.11

function buildDockerImage() {
    IMAGE=$1
    FILE=$2
    docker build -t $IMAGE -f $FILE .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function nvidiaJDK8() {
    buildDockerImage "tornado-gpu" "dockerFiles/Dockerfile.nvidia"
}

function nvidiaGraalVMJDK8() {
    buildDockerImage "tornado-gpu-graalvm-jdk8" "dockerFiles/Dockerfile.nvidia.graalvm.jdk8"
}

function nvidiaGraalVMJDK11() {
    buildDockerImage "tornado-gpu-graalvm-jdk11" "dockerFiles/Dockerfile.nvidia.graalvm.jdk11"
}

function intelJDK8() {
    buildDockerImage "tornado-intel-gpu" "dockerFiles/Dockerfile.intel.igpu"
}

function intelGraalVMJDK8() {
    buildDockerImage "tornado-intel-igpu-graalvm-jdk8" "dockerFiles/Dockerfile.intel.igpu.graalvm.jdk8"
}

function intelGraalVMJDK11() {
    buildDockerImage "tornado-intel-igpu-graalvm-jdk11" "dockerFiles/Dockerfile.intel.igpu.graalvm.jdk11"
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
  --nvidia-graalVM-JDK11)
    nvidiaGraalVMJDK11
    shift
    ;;
  --igpu-jdk8)
    intelJDK8
    shift
    ;;
  --igpu-graalVM-JDK8)
    intelGraalVMJDK8
    shift
    ;;
  --igpu-graalVM-JDK11)
    intelGraalVMJDK11
    shift
    ;;
  esac
done
