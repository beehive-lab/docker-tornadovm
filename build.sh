#!/bin/bash 

TAG_VERSION=0.14

function buildDockerImage() {
    IMAGE=$1
    FILE=$2
    docker build -t $IMAGE -f $FILE .
    docker tag $IMAGE beehivelab/$IMAGE:$TAG_VERSION
    docker tag $IMAGE beehivelab/$IMAGE:latest
}

function nvidiaJDK17() {
    buildDockerImage "tornadovm-nvidia-openjdk" "dockerFiles/Dockerfile.nvidia.jdk17"
}

function nvidiaGraalVMJDK17() {
    buildDockerImage "tornadovm-nvidia-graalvm" "dockerFiles/Dockerfile.nvidia.graalvm.jdk17"
}

function intelJDK17() {
    buildDockerImage "tornadovm-intel-openjdk" "dockerFiles/Dockerfile.oneapi.intel.jdk17"
}

function intelGraalVMJDK17() {
    buildDockerImage "tornadovm-intel-graalvm" "dockerFiles/Dockerfile.oneapi.intel.graalvm.jdk17"
}

function printHelp() {
    echo "TornadoVM Docker Build"
    echo -e "\nOptions: "
    echo "Builds for NVIDIA GPUs:"
    echo "       --nvidia-jdk17         (OpenCL): Build Docker Image for NVIDIA GPUs using JDK11"
    echo "       --nvidia-graalVM-JDK17 (OpenCL): Build Docker Image for NVIDIA GPUs using GraalVM JDK11"
    echo -e "\nBuilds for Intel Integrated GPUs, Intel CPUs and FPGAs (Emulation Mode):"
    echo "       --intel-jdk17          (OpenCL, SPIR-V): Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using JDK17"
    echo "       --intel-graalVM-JDK17  (OpenCL, SPIR-V): Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using GraalVM JDK17"
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
  --nvidia-jdk17)
    nvidiaJDK17
    shift
    ;;
  --nvidia-graalVM-JDK17)
    nvidiaGraalVMJDK17
    shift
    ;;
  --intel-jdk17)
    intelJDK17
    shift
    ;;
  --intel-graalVM-JDK17)
    intelGraalVMJDK17
    shift
    ;;
  esac
done
