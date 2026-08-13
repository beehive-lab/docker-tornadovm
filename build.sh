#!/bin/bash

TAG_VERSION=5.2.0-jdk21

## EXPERIMENTAL — JVMCI-free JDK 27+ ("jdk22plus") profile. Versioned independently from
## TAG_VERSION above (it tracks a different, not-yet-released TornadoVM line) — override
## with `TAG_VERSION_JDK22PLUS=6.1.0 ./build.sh --nvidia-jdk22plus`, e.g. from the GitHub
## workflow, which derives it from the same `version` input the stable images use, just
## without the `-jdk21` suffix. Not touched by bump-version.sh.
TAG_VERSION_JDK22PLUS="${TAG_VERSION_JDK22PLUS:-6.0.0}"

function buildDockerImage() {
    local IMAGE=$1
    local FILE=$2
    local VERSION=${3:-$TAG_VERSION}
    local EXTRA_ARGS=("${@:4}")
    docker build -t "$IMAGE" --progress=plain -f "$FILE" "${EXTRA_ARGS[@]}" .
    docker tag "$IMAGE" "beehivelab/$IMAGE:$VERSION"
    docker tag "$IMAGE" "beehivelab/$IMAGE:latest"
}

function nvidiaJDK21() {
    buildDockerImage "tornadovm-nvidia-openjdk" "dockerFiles/Dockerfile.nvidia.jdk21"
}

function nvidiaGraalVMJDK21() {
    buildDockerImage "tornadovm-nvidia-graalvm" "dockerFiles/Dockerfile.nvidia.graalvm.jdk21"
}

function intelJDK21() {
    buildDockerImage "tornadovm-intel-openjdk" "dockerFiles/Dockerfile.oneapi.intel.jdk21"
}

function intelGraalVMJDK21() {
    buildDockerImage "tornadovm-intel-graalvm" "dockerFiles/Dockerfile.oneapi.intel.graalvm.jdk21"
}

## EXPERIMENTAL — JVMCI-free JDK 27+ ("jdk22plus") profile, built via the `make jdk27`
## Makefile target. TORNADO_TAG (the TornadoVM ref baked into the image) is the bare
## "v${TAG_VERSION_JDK22PLUS}" — see the Dockerfiles' header comments for why it's still
## a placeholder today.
function nvidiaJDK22Plus() {
    buildDockerImage "tornadovm-nvidia-jdk22plus" "dockerFiles/Dockerfile.nvidia.jdk22plus" \
        "$TAG_VERSION_JDK22PLUS" --build-arg "TORNADO_TAG=v${TAG_VERSION_JDK22PLUS}"
}

function intelJDK22Plus() {
    buildDockerImage "tornadovm-intel-jdk22plus" "dockerFiles/Dockerfile.oneapi.intel.jdk22plus" \
        "$TAG_VERSION_JDK22PLUS" --build-arg "TORNADO_TAG=v${TAG_VERSION_JDK22PLUS}"
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
    echo -e "\nEXPERIMENTAL — JVMCI-free JDK 27+ (best-effort; see the Dockerfile header for status/known gaps)"
    echo "       --nvidia-jdk22plus     (OpenCL) : Build Docker Image for NVIDIA GPUs using JDK 27 (JVMCI-free)"
    echo "       --intel-jdk22plus      (OpenCL) : Build Docker Image for Intel Integrated GPUs using JDK 27 (JVMCI-free, unvalidated)"
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
  --nvidia-jdk22plus)
    nvidiaJDK22Plus
    shift
    ;;
  --intel-jdk22plus)
    intelJDK22Plus
    shift
    ;;
  esac
done
