# Docker for Tornado-GPU


![](https://img.shields.io/docker/pulls/beehivelab/tornado-gpu.svg)  [![](https://img.shields.io/badge/License-Apache%202.0-orange.svg)](https://opensource.org/licenses/Apache-2.0)

## Prerequisites

The `tornado-gpu` docker image needs the docker `nvidia` daemon. 
More info here: [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker).

## How to run?

1) Pull the image

```bash
$ docker pull beehivelab/tornado-gpu:latest
```

2) Run an experiment

We provide a runner script that compiles and run your Java programs with Tornado. Here's an example: 

```bash
$ git clone https://github.com/beehive-lab/docker-tornado
$ cd docker-tornado

## Compile Matrix Multiplication - provided in the docker-tornado repository
$ ./run.sh javac.py example/MatrixMultiplication.java

## Run with TornadoVM on the NVIDIA GPU !
$ ./run.sh tornado example/MatrixMultiplication 2048   ## Running on NVIDIA GP100
Computing MxM of 2048x2048
	CPU Execution: 0.36 GFlops, Total time = 48254 ms
	GPU Execution: 277.09 GFlops, Total Time = 62 ms
	Speedup: 778x 
```

### Some options

```bash
# To see the generated OpenCL kernel
$ ./run.sh tornado --printKernel example/MatrixMultiplication

# To check some runtime info about the kernel execution and device
$ ./run.sh tornado --debug example/MatrixMultiplication
```

The `tornado` command is just an alias to the `java` command with all the parameters for TornadoVM execution. So you can pass any Java (OpenJDK or Hotspot) parameter.

```bash
$ ./run.sh tornado -Xmx16g -Xms16g example/MatrixMultiplication
```

Enjoy Tornado!! 

Docker scripts have been inspired by [blang/latex-docker](https://github.com/blang/latex-docker)
