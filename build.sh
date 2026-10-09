#!/bin/bash

TAG_VERSION=7.0.0-jdk21

## DEPRECATED — Intel "jdk22plus" image (source build, runs unchanged on JDK 22-27+).
## Versioned independently from TAG_VERSION above — override with
## `TAG_VERSION_JDK22PLUS=7.2.0 ./build.sh --intel-jdk22plus`. Not touched by
## bump-version.sh, and no longer built by the GitHub workflow.
TAG_VERSION_JDK22PLUS="${TAG_VERSION_JDK22PLUS:-7.2.0}"

## NVIDIA images built from TornadoVM's prebuilt release SDKs (CUDA + OpenCL, Temurin JDK
## 21, 25 and 27) — the images the GitHub workflow builds and pushes. JDK 21 uses the jdk21
## SDK (Dockerfile.nvidia.<backend>.jdk21); any JDK from 22 up uses the jdk22plus SDK
## (Dockerfile.nvidia.<backend>.jdk22plus, with --build-arg JDK_VERSION=<jdk>). Bare TornadoVM release
## version: used as the image tag, and as TORNADO_TAG "v${TORNADOVM_VERSION}" to pick the
## SDK. Override with `TORNADOVM_VERSION=7.2.0 ./build.sh --nvidia-cuda-jdk25`.
TORNADOVM_VERSION="${TORNADOVM_VERSION:-7.2.0}"

function buildDockerImage() {
    local IMAGE=$1
    local FILE=$2
    local VERSION=${3:-$TAG_VERSION}
    local EXTRA_ARGS=("${@:4}")
    docker build -t "$IMAGE" --progress=plain -f "$FILE" "${EXTRA_ARGS[@]}" .
    docker tag "$IMAGE" "beehivelab/$IMAGE:$VERSION"
    docker tag "$IMAGE" "beehivelab/$IMAGE:latest"
}

function nvidiaSDKImage() {
    local BACKEND=$1
    local JDK=$2
    local ARGS=(--build-arg "TORNADO_TAG=v${TORNADOVM_VERSION}")
    local FILE="dockerFiles/Dockerfile.nvidia.${BACKEND}.jdk21"
    if [[ "$JDK" -ge 22 ]]; then
        FILE="dockerFiles/Dockerfile.nvidia.${BACKEND}.jdk22plus"
        ARGS+=(--build-arg "JDK_VERSION=${JDK}")
    elif [[ "$JDK" -ne 21 ]]; then
        echo "Unsupported JDK $JDK: use 21, or 22 and later." >&2
        exit 1
    fi
    buildDockerImage "tornadovm-nvidia-${BACKEND}-jdk${JDK}" "$FILE" "$TORNADOVM_VERSION" "${ARGS[@]}"
}

## DEPRECATED — legacy images below are no longer built by the GitHub workflow.
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

## EXPERIMENTAL — unified "jdk22plus" profile, built via the `make jdk22plus` Makefile
## target (runs unchanged on JDK 22-27+; see the Dockerfiles' header comments).
## TORNADO_TAG (the TornadoVM ref baked into the image) is the bare
## "v${TAG_VERSION_JDK22PLUS}".
function intelJDK22Plus() {
    buildDockerImage "tornadovm-intel-jdk22plus" "dockerFiles/Dockerfile.oneapi.intel.jdk22plus" \
        "$TAG_VERSION_JDK22PLUS" --build-arg "TORNADO_TAG=v${TAG_VERSION_JDK22PLUS}"
}

function printHelp() {
    echo "TornadoVM Docker Build"
    echo -e "\nOptions: "
    echo "Builds for NVIDIA GPUs from the prebuilt TornadoVM SDK (v\$TORNADOVM_VERSION, currently v${TORNADOVM_VERSION})"
    echo "       --nvidia-cuda-jdk21    (CUDA)   : Build Docker Image for NVIDIA GPUs using Temurin JDK21"
    echo "       --nvidia-cuda-jdk25    (CUDA)   : Build Docker Image for NVIDIA GPUs using Temurin JDK25 (jdk22plus SDK)"
    echo "       --nvidia-cuda-jdk27    (CUDA)   : Build Docker Image for NVIDIA GPUs using Temurin JDK27 (jdk22plus SDK)"
    echo "       --nvidia-opencl-jdk21  (OpenCL) : Build Docker Image for NVIDIA GPUs using Temurin JDK21"
    echo "       --nvidia-opencl-jdk25  (OpenCL) : Build Docker Image for NVIDIA GPUs using Temurin JDK25 (jdk22plus SDK)"
    echo "       --nvidia-opencl-jdk27  (OpenCL) : Build Docker Image for NVIDIA GPUs using Temurin JDK27 (jdk22plus SDK)"
    echo "       --nvidia-<cuda|opencl>-jdk<N>    : Any other Temurin JDK from 22 up (unpublished, untested)"
    echo -e "\nDEPRECATED — legacy images, no longer built by the GitHub workflow"
    echo "Builds for NVIDIA Compute Platforms: GPUs"
    echo "       --nvidia-jdk21         (OpenCL) : Build Docker Image for NVIDIA GPUs using JDK21"
    echo "       --nvidia-graalVM-JDK21 (OpenCL) : Build Docker Image for NVIDIA GPUs using GraalVM JDK21"
    echo -e "\nBuilds for Intel Compute Platforms: Integrated GPUs, Intel CPUs and FPGAs (Emulation Mode)"
    echo "       --intel-jdk21          (OpenCL) : Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using JDK21"
    echo "       --intel-graalVM-JDK21  (OpenCL) : Build Docker Image for Intel Integrated GPUs, Intel CPUs, and Intel FPGAs using GraalVM JDK21"
    echo -e "\nEXPERIMENTAL — unified jdk22plus profile, JDK 22-27+ (best-effort; see the Dockerfile header for status/known gaps)"
    echo "       --intel-jdk22plus      (OpenCL) : Build Docker Image for Intel Integrated GPUs using the jdk22plus profile (unvalidated)"
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
  --nvidia-cuda-jdk[0-9]*)
    nvidiaSDKImage cuda "${key#--nvidia-cuda-jdk}"
    shift
    ;;
  --nvidia-opencl-jdk[0-9]*)
    nvidiaSDKImage opencl "${key#--nvidia-opencl-jdk}"
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
  --intel-jdk22plus)
    intelJDK22Plus
    shift
    ;;
  *)
    echo "Unknown option: $key" >&2
    printHelp
    ;;
  esac
done
