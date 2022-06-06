#!/bin/env bash 

platform=$1

if [ -v $1 ];then
    echo "BUILDING DOCKER IMAGES FOR THE $1 PLATFORM"
else
    platform="intel"
    echo "BUILDING DOCKER IMAGES FOR THE $platform PLATFORM"
fi

if [[ $platform == "intel" ]]; then
    ./build.sh --intel-jdk17
    ./run_intel_openjdk.sh tornado -version
    ./run_intel_openjdk.sh tornado --version
    ./run_intel_openjdk.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication


    ./build.sh --intel-graalVM-JDK17
    ./run_intel_graalvm.sh tornado --version
    ./run_intel_graalvm.sh tornado -version
    ./run_intel_graalvm.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication

elif [[ $platform == "nvidia" ]]; then
    ./build.sh --nvidia-jdk17
    ./run_nvidia_openjdk.sh tornado -version
    ./run_nvidia_openjdk.sh tornado --version
    ./run_nvidia_openjdk.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication


    ./build.sh --nvidia-graalVM-JDK17
    ./run_nvidia_graalvm.sh tornado --version
    ./run_nvidia_graalvm.sh tornado -version
    ./run_nvidia_graalvm.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication
fi