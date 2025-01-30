#!/bin/bash 

TAG_VERSION=1.0.10

function buildDockerImage() {
    IMAGE=$1
    FILE=$2
    docker build -t $IMAGE -f $FILE .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function nvidiaJDK21() {
    buildDockerImage "tornadovm-nvidia-openjdk" "dockerFiles/Dockerfile.nvidia.jdk21"
}

function nvidiaGraalVMJDK21() {
    buildDockerImage "tornadovm-nvidia-graalvm" "dockerFiles/Dockerfile.nvidia.graalvm.jdk21"
}


function nvidiaARM() {
    buildDockerImage "tornadovm-nvidia-graalvm-arm" "dockerFiles/Dockerfile.nvidia.graalvm.ptx.jdk21"
}

function intelJDK21() {
    buildDockerImage "tornadovm-intel-openjdk" "dockerFiles/Dockerfile.oneapi.intel.jdk21"
}

function intelGraalVMJDK21() {
    buildDockerImage "tornadovm-intel-graalvm" "dockerFiles/Dockerfile.oneapi.intel.graalvm.jdk21"
}

function printHelp() {
    echo "TornadoVM Docker Build"
    echo -e "\nOptions: "
    echo "Builds for NVIDIA Compute Platforms: GPUs"
    echo "       --nvidia-jdk21         (OpenCL) : Build Docker Image for NVIDIA GPUs using JDK21"
    echo "       --nvidia-graalVM-JDK21 (OpenCL) : Build Docker Image for NVIDIA GPUs using GraalVM JDK21"
    echo -e "\nBuilds for Intel Compute Platforms: Integrated GPUs, Intel CPUs and FPGAs (Emulation Mode)"
    echo "       --intel-jdk21          (OpenCL) : Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using JDK21"
    echo "       --intel-graalVM-JDK21  (OpenCL) : Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using GraalVM JDK21"
    echo "Builds for NVIDIA-ARM Compute Platforms: GPUs"
    echo "       --nvidia-arm-graalVM-JDK17 (PTX): Build Docker Image for NVIDIA GPUs using GraalVM JDK11"
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
  --nvidia-jdk21)
    nvidiaJDK21
    shift
    ;;
  --nvidia-graalVM-JDK21)
    nvidiaGraalVMJDK21
    shift
    ;;
  --intel-jdk21)
    intelJDK21
    shift
    ;;
  --intel-graalVM-JDK21)
    intelGraalVMJDK21
    shift
    ;;
 --nvidia-arm-graalVM-JDK21)
    nvidiaARM
    shift
    ;;
  esac
done
