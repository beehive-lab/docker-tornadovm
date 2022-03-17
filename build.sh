#!/bin/bash 

TAG_VERSION=0.13

function buildDockerImage() {
    IMAGE=$1
    FILE=$2
    docker build -t $IMAGE -f $FILE .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function nvidiaJDK11() {
    buildDockerImage "tornado-gpu" "dockerFiles/Dockerfile.nvidia"
}

function nvidiaGraalVMJDK11() {
    buildDockerImage "tornado-gpu-graalvm-jdk11" "dockerFiles/Dockerfile.nvidia.graalvm.jdk11"
}

function intelJDK11() {
    buildDockerImage "tornado-intel-gpu" "dockerFiles/Dockerfile.intel.igpu"
}

function intelGraalVMJDK11() {
    buildDockerImage "tornado-intel-igpu-graalvm-jdk11" "dockerFiles/Dockerfile.intel.igpu.graalvm.jdk11"
}

function printHelp() {
    echo "TornadoVM docker build"
    echo "Options: "
    echo "Builds for NVIDIA GPUs:"
    echo "       --nvidia-jdk11         (OpenCL): Build Docker Image for NVIDIA GPUs using JDK11"
    echo "       --nvidia-graalVM-JDK11 (OpenCL): Build Docker Image for NVIDIA GPUs using GraalVM JDK11"
    echo -e "\nBuilds for Intel Integrated GPUs:"
    echo "       --igpu-jdk11           (OpenCL): Build Docker Image for Intel Integrated GPUs using JDK11"
    echo "       --igpu-graalVM-JDK11   (OpenCL): Build Docker Image for Intel Integrated GPUs using GraalVM JDK11"
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
  --nvidia-jdk11)
    nvidiaJDK11
    shift
    ;;
  --nvidia-graalVM-JDK11)
    nvidiaGraalVMJDK11
    shift
    ;;
  --igpu-jdk11)
    intelJDK11
    shift
    ;;
  --igpu-graalVM-JDK11)
    intelGraalVMJDK11
    shift
    ;;
  esac
done
