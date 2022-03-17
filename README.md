# Docker for TornadoVM

![](https://img.shields.io/docker/pulls/beehivelab/tornado-gpu.svg?color=green&label=docker%20pulls%20nvidia%20jdk8) ![](https://img.shields.io/docker/pulls/beehivelab/tornado-gpu-graalvm-jdk8.svg?color=green&label=docker%20pulls%20nvidia%20graal%20jdk8) ![](https://img.shields.io/docker/pulls/beehivelab/tornado-gpu-graalvm-jdk11.svg?color=green&label=docker%20pulls%20nvidia%20graal%20jdk11)

![](https://img.shields.io/docker/pulls/beehivelab/tornado-intel-gpu.svg?color=blue&label=docker%20pulls%20intel%20jdk8)  ![](https://img.shields.io/docker/pulls/beehivelab/tornado-intel-igpu-graalvm-jdk8.svg?color=blue&label=docker%20pulls%20intel%20graal%20jdk8)  ![](https://img.shields.io/docker/pulls/beehivelab/tornado-intel-igpu-graalvm-jdk11.svg?color=blue&label=docker%20pulls%20intel%20graal%20jdk11)  

[![](https://img.shields.io/badge/License-Apache%202.0-orange.svg)](https://opensource.org/licenses/Apache-2.0)

We have two docker configurations for TornadoVM using 2 different JDKs:

* TornadoVM Docker for **NVIDIA GPUs**: See [instructions](https://github.com/beehive-lab/docker-tornado#nvidia-gpus)
    * JDKs supported:
	    * TornadoVM with OpenJDK 11
		* TornadoVM with GraalVM 21.3.0 and JDK 11
* TornadoVM Docker for **Intel Integrated Graphics**: See [instructions](https://github.com/beehive-lab/docker-tornado#intel-intergrated-graphics)
    * JDKs supported:
	    * TornadoVM with OpenJDK 11
		* TornadoVM with GraalVM 21.3.0 and JDK 11

## Nvidia GPUs

### Prerequisites

The `tornado-gpu` docker image needs the docker `nvidia` daemon.  More info here: [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker).

### How to run?

1) Pull the image

For the `nvidia` image:
```bash
$ docker pull beehivelab/tornado-gpu:latest
```

This image uses the latest TornadoVM for NVIDIA GPUs and OpenJDK 8.

2) Run an experiment

We provide a runner script that compiles and run your Java programs with Tornado. Here's an example:

```bash
$ git clone https://github.com/beehive-lab/docker-tornado
$ cd docker-tornado

## Compile Matrix Multiplication - provided in the docker-tornado repository
$ ./run_nvidia.sh javac.py example/MatrixMultiplication.java

## Run with TornadoVM on the NVIDIA GPU !
$ ./run_nvidia.sh tornado example/MatrixMultiplication 2048   ## Running on NVIDIA GP100
Computing MxM of 2048x2048
	CPU Execution: 0.36 GFlops, Total time = 48254 ms
	GPU Execution: 277.09 GFlops, Total Time = 62 ms
	Speedup: 778x 
```

### Using TornadoVM with GraalVM for NVIDIA GPUs

With JDK 11:

```bash
$ docker pull beehivelab/tornado-gpu-graalvm-jdk11:latest
```

### Some options

```bash
# To see the generated OpenCL kernel
$ ./run_nvidia.sh tornado --printKernel example/MatrixMultiplication

# To check some runtime info about the kernel execution and device
$ ./run_nvidia.sh tornado --debug example/MatrixMultiplication
```

The `tornado` command is just an alias to the `java` command with all the parameters for TornadoVM execution. So you can pass any Java (OpenJDK or Hotspot) parameter.

```bash
$ ./run_nvidia.sh tornado -Xmx16g -Xms16g example/MatrixMultiplication
```

## Intel Integrated Graphics

### Prerequisites

The `tornado-intel-gpu` docker image Intel OpenCL driver for the integrated GPU installed.  More info here: [https://github.com/intel/compute-runtime](https://github.com/intel/compute-runtime).

### How to run?

1) Pull the image

For the `intel-gpu` image:
```bash
$ docker pull beehivelab/tornado-intel-gpu:latest
```

This image uses the latest TornadoVM for Intel integrated graphics and OpenJDK 8.

2) Run an experiment

We provide a runner script that compiles and run your Java programs with Tornado. Here's an example:

```bash
$ git clone https://github.com/beehive-lab/docker-tornado
$ cd docker-tornado

## Compile Matrix Multiplication - provided in the docker-tornado repository
$ ./run_intel.sh javac.py example/MatrixMultiplication.java

## Run with TornadoVM on the Intel Intergrated GPU !
$ ./run_intel.sh tornado example/MatrixMultiplication 256   ## Running on Intel(R) Gen9 HD Graphics
Computing MxM of 256x256
	CPU Execution: 1.53 GFlops, Total time = 22 ms
	GPU Execution: 8.39 GFlops, Total Time = 4 ms
	Speedup: 5x

```

### Using TornadoVM with GraalVM for Intel Integrated Graphics

With JDK 11:

```bash
$ docker pull beehivelab/tornado-intel-igpu-graalvm-jdk11:latest
```


Enjoy Tornado!! 

Docker scripts have been inspired by [blang/latex-docker](https://github.com/blang/latex-docker)
